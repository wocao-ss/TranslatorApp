package com.example.translator

import android.Manifest
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.material.button.MaterialButton
import com.google.android.material.progressindicator.CircularProgressIndicator
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import java.util.Locale

class MainActivity : AppCompatActivity() {

    private lateinit var etInput: EditText
    private lateinit var tvOutput: TextView
    private lateinit var tvSourceLang: TextView
    private lateinit var tvTargetLang: TextView
    private lateinit var btnTranslate: MaterialButton
    private lateinit var btnSwapLang: MaterialButton
    private lateinit var btnVoiceInput: MaterialButton
    private lateinit var btnSpeakOutput: MaterialButton
    private lateinit var btnCopy: MaterialButton
    private lateinit var progressBar: CircularProgressIndicator

    private var textToSpeech: TextToSpeech? = null
    private var isChineseToUzbek = true
    
    private val speechLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            val data = result.data
            val matches = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            if (!matches.isNullOrEmpty()) {
                etInput.setText(matches[0])
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        initViews()
        initTextToSpeech()
        setupListeners()
        checkPermissions()
    }

    private fun initViews() {
        etInput = findViewById(R.id.etInput)
        tvOutput = findViewById(R.id.tvOutput)
        tvSourceLang = findViewById(R.id.tvSourceLang)
        tvTargetLang = findViewById(R.id.tvTargetLang)
        btnTranslate = findViewById(R.id.btnTranslate)
        btnSwapLang = findViewById(R.id.btnSwapLang)
        btnVoiceInput = findViewById(R.id.btnVoiceInput)
        btnSpeakOutput = findViewById(R.id.btnSpeakOutput)
        btnCopy = findViewById(R.id.btnCopy)
        progressBar = findViewById(R.id.progressBar)
    }

    private fun initTextToSpeech() {
        textToSpeech = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                // TTS initialized successfully
            }
        }
    }

    private fun setupListeners() {
        btnTranslate.setOnClickListener {
            val text = etInput.text.toString().trim()
            if (text.isNotEmpty()) {
                translateText(text)
            } else {
                Toast.makeText(this, "请输入文字", Toast.LENGTH_SHORT).show()
            }
        }

        btnSwapLang.setOnClickListener {
            swapLanguages()
        }

        btnVoiceInput.setOnClickListener {
            startVoiceInput()
        }

        btnSpeakOutput.setOnClickListener {
            speakOutput()
        }

        btnCopy.setOnClickListener {
            copyToClipboard()
        }
    }

    private fun checkPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                REQUEST_RECORD_AUDIO_PERMISSION
            )
        }
    }

    private fun swapLanguages() {
        isChineseToUzbek = !isChineseToUzbek
        if (isChineseToUzbek) {
            tvSourceLang.text = getString(R.string.lang_chinese)
            tvTargetLang.text = getString(R.string.lang_uzbek)
        } else {
            tvSourceLang.text = getString(R.string.lang_uzbek)
            tvTargetLang.text = getString(R.string.lang_chinese)
        }
        // Clear output when swapping
        tvOutput.text = ""
    }

    private fun translateText(text: String) {
        showLoading(true)

        val sourceLang = if (isChineseToUzbek) {
            TranslateLanguage.CHINESE
        } else {
            TranslateLanguage.UZBEK
        }

        val targetLang = if (isChineseToUzbek) {
            TranslateLanguage.UZBEK
        } else {
            TranslateLanguage.CHINESE
        }

        val options = TranslatorOptions.Builder()
            .setSourceLanguage(sourceLang)
            .setTargetLanguage(targetLang)
            .build()

        val translator = Translation.getClient(options)

        val conditions = DownloadConditions.Builder()
            .requireWifi()
            .build()

        translator.downloadModelIfNeeded(conditions)
            .addOnSuccessListener {
                translator.translate(text)
                    .addOnSuccessListener { translatedText ->
                        tvOutput.text = translatedText
                        showLoading(false)
                        translator.close()
                    }
                    .addOnFailureListener { exception ->
                        showError("翻译失败: ${exception.message}")
                        showLoading(false)
                        translator.close()
                    }
            }
            .addOnFailureListener { exception ->
                showError("模型下载失败: ${exception.message}")
                showLoading(false)
                translator.close()
            }
    }

    private fun startVoiceInput() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(this, getString(R.string.permission_denied), Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, if (isChineseToUzbek) "zh-CN" else "uz-UZ")
            putExtra(RecognizerIntent.EXTRA_PROMPT, "请说话...")
        }

        try {
            speechLauncher.launch(intent)
        } catch (e: Exception) {
            Toast.makeText(this, "语音识别不可用", Toast.LENGTH_SHORT).show()
        }
    }

    private fun speakOutput() {
        val text = tvOutput.text.toString()
        if (text.isEmpty()) {
            Toast.makeText(this, "没有可朗读的内容", Toast.LENGTH_SHORT).show()
            return
        }

        val locale = if (isChineseToUzbek) {
            Locale("uz", "UZ")
        } else {
            Locale.CHINESE
        }

        textToSpeech?.language = locale
        textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    private fun copyToClipboard() {
        val text = tvOutput.text.toString()
        if (text.isNotEmpty()) {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("翻译结果", text)
            clipboard.setPrimaryClip(clip)
            Toast.makeText(this, "已复制到剪贴板", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showLoading(show: Boolean) {
        progressBar.visibility = if (show) android.view.View.VISIBLE else android.view.View.GONE
        btnTranslate.isEnabled = !show
    }

    private fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        textToSpeech?.stop()
        textToSpeech?.shutdown()
    }

    companion object {
        private const val REQUEST_RECORD_AUDIO_PERMISSION = 200
    }
}
