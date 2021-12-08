import $ from 'jquery';
window.jQuery = $;
window.$ = $;
import 'popper.js';
import 'bootstrap';

import '../scss/application.scss'


$(document).ready(function () {
    var tags = $('select#tags');
    if (tags.select2) {
        $('select#tags').select2({
            tags: true,
            tokenSeparators: [','],
        });    
    }    

    if (document.querySelector('#ck-content')) {
        ClassicEditor
            .create(document.querySelector('#ck-content'), {
                language: 'ru', //to set different lang include <script src="/public/js/ckeditor/build/translations/{lang}.js"></script> along with core ckeditor script
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
            $('.public-body .navbar').addClass("fixed-top");
        } else {
            $('.public-body .navbar').removeClass("fixed-top");
        }
    });
});

document.addEventListener("DOMContentLoaded", function () {
    
});
