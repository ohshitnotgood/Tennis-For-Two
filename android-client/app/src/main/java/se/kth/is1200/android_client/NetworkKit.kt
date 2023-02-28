package se.kth.is1200.android_client

import com.neovisionaries.ws.client.WebSocket
import com.neovisionaries.ws.client.WebSocketAdapter
import com.neovisionaries.ws.client.WebSocketFactory
class NetworkKit {
    fun connectToServer(address: String) {
        println("Connecting to address $address")
        val ws = WebSocketFactory().createSocket(address)
        ws.sendText("0x001")
        ws.addListener( object: WebSocketAdapter() {
            override fun onTextMessage(websocket: WebSocket?, text: String?) {
                super.onTextMessage(websocket, text)
                println("Received message from server: $text")
            }
        })
    }

}