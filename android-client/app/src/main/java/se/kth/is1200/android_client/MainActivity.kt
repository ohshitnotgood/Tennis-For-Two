package se.kth.is1200.android_client

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.*
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

class MainActivity : AppCompatActivity() {
    /**
     * Global variable that stores the x-coordinate of the paddle.
     *
     * This is the data that will be sent to the esp8688 chip.
     */
    private var accXPC = 0

    /**
     * Global variable that stores the y-coordinate of the paddle.
     *
     * This is the data that will be sent to the esp8688 chip.
     */
    private var accYPC = 0

    // If you want to do something immediately after the app launches, write it in here.
    // Look up Android Activity Life Cycle if you want other events like onPause, onResume, etc.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        publishAccelerometerData()
        publishGyroscopeData()
    }

    /**
     * Prints accelerometer data onto the screen. Expect this to be very noisy.
     */
    private fun publishAccelerometerData() {
        // Getting access to the sensor.
        // Also, val is const in Kotlin.
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager

        // Linear acceleration is different from a normal sensor in the way that it supposedly
        // removes acceleration from gravity before it spits out data.
        // Read more here: https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-linear
        val sensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)

        // This is an event listener. Every time the sensor data changes, whatever inside this
        // function gets executed.
        //
        // Currently this is displaying the data straight from the accelerometer
        // on to the phone's display
        //
        val sensorEventListener = object : SensorEventListener {
            override fun onSensorChanged(p0: SensorEvent?) {
                // accXTV is an TextView object. The id inside the findViewById function is
                // defined in the activity_main.xml file.
                //
                // p0.values has the latest data from the sensor.
                //
                val accXTV: TextView = findViewById(R.id.acc_d_x)
                accXTV.text = p0!!.values[0].toString()

                // Same shit, different axis.
                val accYTV: TextView = findViewById(R.id.acc_d_y)
                accYTV.text = p0.values[1].toString()
                
                // Same shit, different axis.
                val accZTV: TextView = findViewById(R.id.acc_d_z)
                accZTV.text = p0.values[2].toString()

                // This function is where you actually need to work on.
                publishCoordinateData(p0.values[0], p0.values[1])
            }

            // Ignore this for now. This is a mandatory function that needs to be
            // overridden so don't remove this.
            override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
                print("Called in onAccuracyChanged")
            }
        }

        // Registering the event listener into the sensor object.
        sensorManager.registerListener(sensorEventListener, sensor, 1)
    }

    /**
     * Prints coordinates onto the display.
     *
     * @param accX Unprocessed x-axis data coming in straight from the accelerometer.
     * @param accY Unprocessed y-axis data coming in straight from the accelerometer.
     */
    @SuppressLint("SetTextI18n")
    private fun publishCoordinateData(accX: Float, accY: Float) {

        accXPC += (accX * 10).toInt()
        accYPC += (accY * 10).toInt()

        val xpc: TextView = findViewById(R.id.xpc)
        val ypx:TextView = findViewById(R.id.ypc)

        xpc.text = "($accXPC"

        ypx.text = ", $accYPC)"
    }

    /**
     * Displays gyroscope data onto the display. Expect this to be very noisy.
     */
    private fun publishGyroscopeData() {
        // This function is doing the same thing as the accelerometer sensor function, 
        // but this time, it's doing it for the gyroscope data.
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        val gyroEventListener = object : SensorEventListener {
            override fun onSensorChanged(p0: SensorEvent?) {
                val gyroXTV = findViewById<TextView>(R.id.gyro_x)
                gyroXTV.text = p0!!.values[0].toString()

                val gyroYTV = findViewById<TextView>(R.id.gyro_y)
                gyroYTV.text = p0.values[1].toString()

                val gyroZTV = findViewById<TextView>(R.id.gyro_z)
                gyroZTV.text = p0.values[2].toString()
            }

            override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
                print("Gyro accuracy change detected")
            }
        }

        // Attaching event listener to the gyro sensor.
        sensorManager.registerListener(gyroEventListener, sensor, 1)
    }


}