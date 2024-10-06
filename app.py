from flask import Flask, request, jsonify, send_file, render_template
import os
import zipfile
import subprocess

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
APK_FOLDER = 'apks'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(APK_FOLDER, exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'zipfile' not in request.files:
        return jsonify({'error': '未找到文件'}), 400

    zip_file = request.files['zipfile']
    
    # 驗證文件類型
    if not zip_file.filename.endswith('.zip'):
        return jsonify({'error': '僅允許上傳 .zip 文件'}), 400
    
    # 驗證文件大小
    max_size = 50 * 1024 * 1024  # 10MB
    if zip_file.content_length > max_size:
        return jsonify({'error': '文件大小超過限制（最大 50MB）'}), 400

    zip_path = os.path.join(UPLOAD_FOLDER, zip_file.filename)
    zip_file.save(zip_path)

    # 解壓縮 ZIP 文件
    extract_folder = os.path.join(UPLOAD_FOLDER, zip_file.filename[:-4])
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_folder)

    # Cordova 打包 APK
    apk_name = zip_file.filename[:-4] + '.apk'
    apk_path = os.path.join(APK_FOLDER, apk_name)

    try:
        # 進入解壓文件夾並初始化 Cordova 項目
        subprocess.run(['cordova', 'create', 'cordova_app', 'com.example.app', 'MyApp'], check=True, cwd=extract_folder)
        subprocess.run(['cordova', 'platform', 'add', 'android'], check=True, cwd=os.path.join(extract_folder, 'cordova_app'))
        
        # 將用戶上傳的文件拷貝到 Cordova 的 www 文件夾中
        www_folder = os.path.join(extract_folder, 'cordova_app', 'www')
        for item in os.listdir(extract_folder):
            if item != 'cordova_app' and item != zip_file.filename:
                item_path = os.path.join(extract_folder, item)
                if os.path.isdir(item_path):
                    subprocess.run(['cp', '-r', item_path, www_folder], check=True)
                else:
                    subprocess.run(['cp', item_path, www_folder], check=True)

        # 構建 APK
        subprocess.run(['cordova', 'build', 'android', '--release'], check=True, cwd=os.path.join(extract_folder, 'cordova_app'))

        # 查找生成的 APK 文件
        apk_path = os.path.join(extract_folder, 'cordova_app', 'platforms', 'android', 'app', 'build', 'outputs', 'apk', 'release', apk_name)
        if os.path.exists(apk_path):
            return jsonify({'message': 'APK 生成成功', 'apk_url': f'/apks/{apk_name}'})
        else:
            return jsonify({'error': 'APK 生成失敗'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/apks/<path:filename>', methods=['GET'])
def download_apk(filename):
    return send_file(os.path.join(APK_FOLDER, filename), as_attachment=True)

if __name__ == '__main__':
    port = int(os.getenv('PORT', 10000))  # 使用 Render 提供的端口
    app.run(host='0.0.0.0', port=port,debug=True)
