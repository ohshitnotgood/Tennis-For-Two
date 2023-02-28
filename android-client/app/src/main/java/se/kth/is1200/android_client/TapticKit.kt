package se.kth.is1200.android_client

import android.content.Context
import android.os.VibrationEffect
import android.os.Vibrator

object TapticKit {

    fun generateTapticFeedback(context: Context, level: TapticGeneratorLevel) {
        val vibrator = context.getSystemService(Vibrator::class.java)

        when (level) {
            TapticGeneratorLevel.LEVEL_ZERO -> vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
            TapticGeneratorLevel.LEVEL_ONE -> vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK))
            TapticGeneratorLevel.LEVEL_TWO -> vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK))
            TapticGeneratorLevel.LEVEL_THREE -> vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK))
            TapticGeneratorLevel.LEVEL_FOUR -> vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
        }
    }

    enum class TapticGeneratorLevel {
        LEVEL_ZERO, LEVEL_ONE, LEVEL_TWO, LEVEL_THREE, LEVEL_FOUR
    }
}