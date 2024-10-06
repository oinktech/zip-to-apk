$(document).ready(function() {
    $('#uploadForm').on('submit', function(event) {
        event.preventDefault();
        
        let formData = new FormData(this);
        $('#progress').show();
        $('#progressBar').css('width', '0%');

        $.ajax({
            url: '/upload',
            type: 'POST',
            data: formData,
            contentType: false,
            processData: false,
            xhr: function() {
                let xhr = new window.XMLHttpRequest();
                xhr.upload.addEventListener("progress", function(evt) {
                    if (evt.lengthComputable) {
                        let percentComplete = evt.loaded / evt.total * 100;
                        $('#progressBar').css('width', percentComplete + '%');
                    }
                }, false);
                return xhr;
            },
            success: function(response) {
                $('#progress').hide();
                if (response.apk_url) {
                    $('#result').html(`<div class="alert alert-success">APK 生成成功! <a href="${response.apk_url}" class="alert-link" id="downloadLink">點擊下載</a></div>`);
                    // 清空上傳表單
                    $('#uploadForm')[0].reset();
                } else {
                    $('#result').html(`<div class="alert alert-danger">${response.error}</div>`);
                }
            },
            error: function(xhr) {
                $('#progress').hide();
                $('#result').html(`<div class="alert alert-danger">${xhr.responseJSON.error}</div>`);
            }
        });
    });

    $(document).on('click', '#downloadLink', function() {
        setTimeout(() => {
            $('#result').html(`<div class="alert alert-info">正在準備下載，請稍等...</div>`);
        }, 2000);
    });
});
