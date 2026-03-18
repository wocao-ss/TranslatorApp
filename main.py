from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.textinput import TextInput
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.scrollview import ScrollView
from kivy.core.window import Window
from kivy.properties import BooleanProperty
import requests
import json

class TranslatorLayout(BoxLayout):
    is_chinese_to_uzbek = BooleanProperty(True)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.orientation = 'vertical'
        self.padding = 10
        self.spacing = 10
        Window.clearcolor = (0.95, 0.95, 0.95, 1)
        
        self.build_ui()
    
    def build_ui(self):
        # 标题
        title = Label(
            text='中文-乌兹别克语翻译',
            size_hint_y=None,
            height=50,
            font_size='20sp',
            color=(0.2, 0.4, 0.8, 1)
        )
        self.add_widget(title)
        
        # 语言切换区域
        lang_layout = GridLayout(cols=3, size_hint_y=None, height=50, spacing=10)
        
        self.source_lang_label = Label(
            text='中文',
            font_size='16sp',
            color=(0.2, 0.4, 0.8, 1)
        )
        lang_layout.add_widget(self.source_lang_label)
        
        swap_btn = Button(
            text='⇄',
            font_size='20sp',
            background_color=(0.3, 0.5, 0.9, 1)
        )
        swap_btn.bind(on_press=self.swap_languages)
        lang_layout.add_widget(swap_btn)
        
        self.target_lang_label = Label(
            text='乌兹别克语',
            font_size='16sp',
            color=(0.2, 0.4, 0.8, 1)
        )
        lang_layout.add_widget(self.target_lang_label)
        
        self.add_widget(lang_layout)
        
        # 输入区域
        input_label = Label(
            text='输入文字:',
            size_hint_y=None,
            height=30,
            halign='left',
            color=(0.3, 0.3, 0.3, 1)
        )
        self.add_widget(input_label)
        
        self.input_text = TextInput(
            multiline=True,
            hint_text='请输入要翻译的文字...',
            size_hint_y=None,
            height=120,
            font_size='16sp',
            background_color=(1, 1, 1, 1),
            foreground_color=(0, 0, 0, 1)
        )
        self.add_widget(self.input_text)
        
        # 翻译按钮
        translate_btn = Button(
            text='翻译',
            size_hint_y=None,
            height=50,
            font_size='18sp',
            background_color=(0.2, 0.6, 0.9, 1)
        )
        translate_btn.bind(on_press=self.translate)
        self.add_widget(translate_btn)
        
        # 输出区域
        output_label = Label(
            text='翻译结果:',
            size_hint_y=None,
            height=30,
            halign='left',
            color=(0.3, 0.3, 0.3, 1)
        )
        self.add_widget(output_label)
        
        # 使用 ScrollView 包装输出文本
        scroll = ScrollView(size_hint=(1, 1))
        self.output_text = Label(
            text='',
            size_hint_y=None,
            font_size='18sp',
            color=(0, 0, 0, 1),
            text_size=(Window.width - 40, None),
            halign='left',
            valign='top'
        )
        self.output_text.bind(texture_size=self.output_text.setter('size'))
        scroll.add_widget(self.output_text)
        self.add_widget(scroll)
        
        # 复制按钮
        copy_btn = Button(
            text='复制结果',
            size_hint_y=None,
            height=45,
            font_size='16sp',
            background_color=(0.4, 0.7, 0.4, 1)
        )
        copy_btn.bind(on_press=self.copy_result)
        self.add_widget(copy_btn)
        
        # 状态标签
        self.status_label = Label(
            text='就绪',
            size_hint_y=None,
            height=30,
            font_size='12sp',
            color=(0.5, 0.5, 0.5, 1)
        )
        self.add_widget(self.status_label)
    
    def swap_languages(self, instance):
        self.is_chinese_to_uzbek = not self.is_chinese_to_uzbek
        if self.is_chinese_to_uzbek:
            self.source_lang_label.text = '中文'
            self.target_lang_label.text = '乌兹别克语'
        else:
            self.source_lang_label.text = '乌兹别克语'
            self.target_lang_label.text = '中文'
        self.output_text.text = ''
    
    def translate(self, instance):
        text = self.input_text.text.strip()
        if not text:
            self.status_label.text = '请输入文字'
            return
        
        self.status_label.text = '正在翻译...'
        
        try:
            # 使用 Google Translate API (通过 mymemory API)
            if self.is_chinese_to_uzbek:
                source_lang = 'zh-CN'
                target_lang = 'uz'
            else:
                source_lang = 'uz'
                target_lang = 'zh-CN'
            
            # 使用 mymemory API (免费)
            url = f"https://api.mymemory.translated.net/get?q={requests.utils.quote(text)}&langpair={source_lang}|{target_lang}"
            response = requests.get(url, timeout=10)
            data = response.json()
            
            if data.get('responseStatus') == 200:
                translated = data.get('responseData', {}).get('translatedText', '')
                self.output_text.text = translated
                self.status_label.text = '翻译完成'
            else:
                self.status_label.text = f"翻译失败: {data.get('responseDetails', '未知错误')}"
                
        except Exception as e:
            self.status_label.text = f'错误: {str(e)}'
    
    def copy_result(self, instance):
        if self.output_text.text:
            # 在 Android 上使用 Clipboard
            try:
                from kivy.core.clipboard import Clipboard
                Clipboard.copy(self.output_text.text)
                self.status_label.text = '已复制到剪贴板'
            except:
                self.status_label.text = '复制失败'
        else:
            self.status_label.text = '没有可复制的内容'

class TranslatorApp(App):
    def build(self):
        return TranslatorLayout()

if __name__ == '__main__':
    TranslatorApp().run()
