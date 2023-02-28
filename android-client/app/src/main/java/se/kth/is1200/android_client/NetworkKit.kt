package se.kth.is1200.android_client

import com.neovisionaries.ws.client.*
import java.util.logging.Logger

class NetworkKit constructor(private val address: String) {
    private val logger = Logger.getLogger("network_kit")
    private var connectionDidSucceed = false
    private var shouldContinueListening = false
    private var count = 0

    private var socket: WebSocket? = null

    private var hasInitialHandshakeBeenDone = false

    init {
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
    }

    fun connectToServer(): WebSocket? {
        logger.info("Connecting to address $address")

        return try {
            socket!!.connectAsynchronously()
        } catch (e: OpeningHandshakeException) {
            logger.warning("Found OpeningHandshakeException")
            null
        } catch (e: HostnameUnverifiedException) {
            logger.warning("Found HostnameUnverifiedException")
            null
        } catch (e: WebSocketException) {
            logger.warning("Found WebSocketException with message: ${e.message}")
            null
        } catch (e: java.lang.Exception) {
            logger.warning("Caught unknown exception: ${e.localizedMessage}")
            null
        }
    }

    fun initialiseClientSlaveSyncHandshake() {
        socket!!.sendText("0x001")
    }


    private fun messageDecoder(message: String) {
        logger.info("Received message from server. $message")
        socket!!.connectAsynchronously()

        when (message) {
            // Initial Handshake acknowledgement for
            "0x004" -> {
                hasInitialHandshakeBeenDone = true                                                  // client-slave-sync
                logger.info("Received client-slave-sync acknowledgement.")
            }

            // Respond to a data request from the server with
            "0x200" -> {
                socket!!.sendText("response_$count")                                                // Level zero haptic feedback
                logger.info("Data pull request on h_lvl_0")
            }
            "0x201" -> socket!!.sendText("response_$count")                                         // Level one haptic feedback
            "0x202" -> socket!!.sendText("response_$count")                                         // Level two haptic feedback
            "0x203" -> socket!!.sendText("response_$count")                                         // Level three haptic feedback
            "0x204" -> socket!!.sendText("response_$count")                                         // Level four haptic feedback

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

    fun stopListening() {
        this.shouldContinueListening = false
        socket!!.sendText("0x104")
    }
}