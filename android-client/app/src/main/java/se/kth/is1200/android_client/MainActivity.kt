package se.kth.is1200.android_client

import android.content.Context
import android.hardware.*
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        publishAccelerometerData()
        publishCoordinateData()
        publishGyroscopeData()
    }

    private fun publishAccelerometerData() {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)

        val sensorEventListener = object : SensorEventListener {
            override fun onSensorChanged(p0: SensorEvent?) {
                val accXTV: TextView = findViewById(R.id.acc_d_x)
                accXTV.text = p0!!.values[0].toString()

                val accYTV: TextView = findViewById(R.id.acc_d_y)
                accYTV.text = p0.values[1].toString()

                val accZTV: TextView = findViewById(R.id.acc_d_z)
                accZTV.text = p0.values[2].toString()
            }

            override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
                print("Called in onAccuracyChanged")
            }
        }
        sensorManager.registerListener(sensorEventListener, sensor, 1)
    }

    private fun publishCoordinateData() {

    }
    private fun publishGyroscopeData() {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        val gyroEventListener = object : SensorEventListener {
            
        }
    }


}