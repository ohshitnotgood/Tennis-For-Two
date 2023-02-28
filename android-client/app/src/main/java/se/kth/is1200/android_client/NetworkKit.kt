package se.kth.is1200.android_client

import com.neovisionaries.ws.client.*
import java.util.logging.Logger

class NetworkKit {
    private val logger = Logger.getLogger("network_kit")
    private var connectionDidSucceed = false
    private var shouldContinueListening = false
    private var count = 0

    private var socket: WebSocket? = null

    fun connectToServer(address: String): WebSocket? {
        logger.info("Connecting to address $address\n")
        this.socket = WebSocketFactory()
            .createSocket(address, 5000)
            .addListener( object: WebSocketAdapter() {
                override fun onTextMessage(websocket: WebSocket?, text: String?) {
                    super.onTextMessage(websocket, text)
                    logger.info("Received message from server: $text")
                    messageDecoder(text!!)
                }

                override fun onConnected(websocket: WebSocket?,
                                         headers: MutableMap<String, MutableList<String>>?
                ) {
                    super.onConnected(websocket, headers)
                    connectionDidSucceed = true
                    logger.info("Connected to the server")
                }

                override fun onError(websocket: WebSocket?, cause: WebSocketException?) {
                    super.onError(websocket, cause)
                    logger.warning(cause!!.message)
                }

                override fun onDisconnected(
                    websocket: WebSocket?,
                    serverCloseFrame: WebSocketFrame?,
                    clientCloseFrame: WebSocketFrame?,
                    closedByServer: Boolean
                ) {
                    super.onDisconnected(
                        websocket,
                        serverCloseFrame,
                        clientCloseFrame,
                        closedByServer
                    )
                    connectionDidSucceed = false
                }
            })

        return try {
            socket!!.connectAsynchronously()
        } catch (e: OpeningHandshakeException) {
            logger.warning("Found OpeningHandshakeException\n")
            null
        } catch (e: HostnameUnverifiedException) {
            logger.warning("Found HostnameUnverifiedException\n")
            null
        } catch (e: WebSocketException) {
            logger.warning("Found WebSocketException with message: ${e.message}")
            null
        } catch (e: java.lang.Exception) {
            logger.warning("Caught unknown exception: ${e.localizedMessage}")
            null
        }
    }



    fun messageDecoder(message: String) {
        logger.info("Received message from server. $message")

        when (message) {
            "0x201" -> socket!!.sendText("response_$count")
            "0x202" -> socket!!.sendText("response_$count")
            "0x203" -> socket!!.sendText("response_$count")
            "0x204" -> socket!!.sendText("response_$count")
            else -> logger.info("Failed to parse error message")
        }
        count += 1
    }

    fun startListening() {
        this.shouldContinueListening = true
        logger.info("Sending data to initialise client-slave-sync loop")
        try {
            logger.info("Attempting to send 0x101 as a response to the server")
            socket!!.sendText("0x101")
            logger.info("Successfully sent 0x101 as a response to the server")
        } catch (e: Exception) {
            logger.warning("Caught error sending data. ${e.message}")
        }
        logger.info("Sending message to initialise client-slave sync loop")
    }

    fun sendMessage(socket: WebSocket) {
        try {
            socket.sendText("0x001")
        } catch (e: Exception) {
            logger.warning("Failed to send data to the server because of exception: ${e.message}")
        }
    }

    fun stopListening() {
        this.shouldContinueListening = false
    }
}