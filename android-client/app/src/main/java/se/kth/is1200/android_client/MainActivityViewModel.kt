package se.kth.is1200.android_client

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

class MainActivityViewModel constructor(private val address: String): ViewModel() {
    val connectionStatus: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }


}

class MainActivityViewModelFactory constructor(private val address: String): ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MainActivityViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MainActivityViewModel(address=address) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}