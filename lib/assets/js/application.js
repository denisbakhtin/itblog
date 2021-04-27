import xhook from 'xhook';
import $ from 'jquery';
window.jQuery = $;
window.$ = $;
import 'popper.js';
import 'parsleyjs';
import 'bootstrap';
//import 'jquery-slimscroll';
import 'select2';

import '../scss/application.scss'


$(document).ready(function () {
    $('select#tags').select2({
        tags: true,
        tokenSeparators: [','],
    });

    if (document.querySelector('#ck-content')) {
        //add csrf protection to ckeditor uploads
        xhook.before(function (request) {
            if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(request.method)) {
                request.xhr.setRequestHeader("X-CSRF-TOKEN", window.csrf_token);
            }
        });

        ClassicEditor
            .create(document.querySelector('#ck-content'), {
                language: 'en', //to set different lang include <script src="/public/js/ckeditor/build/translations/{lang}.js"></script> along with core ckeditor script
                ckfinder: {
                    uploadUrl: '/admin/upload'
                },
            })
            .catch(error => {
                console.error(error);
            });
    }

    $(window).on("scroll", function () {
        var iCurScrollPos = $(this).scrollTop();
        if (iCurScrollPos > 85) {
            $('.navbar').addClass("fixed-top");
        } else {
            $('.navbar').removeClass("fixed-top");
        }
    });
});