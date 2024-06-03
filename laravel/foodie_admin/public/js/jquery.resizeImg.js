/**
 * jquery.resizeImg.js - get the base64 code of a resized picture
 *
 * Written by
 * ----------
 * Windy2000 (windy2006@gmail.com)
 *
 * Licensed under the Apache License Version 2.0
 *
 * Dependencies
 * ------------
 * jQuery (http://jquery.com)
 *
 **/

$.fn.resizeImg = function(options) {
    let defaults = {
        mode: 0,                    // ç¼©æ”¾æ¨¡å¼ï¼š1 - æŒ‰å®½åº¦ï¼Œ2 - æŒ‰æ¯”ä¾‹ï¼Œ3 - æŒ‰å¤§å°
        val: 800,                   // å¯¹åº”æ¨¡å¼çš„å˜åŒ–å‚æ•°ï¼š1-åƒç´ ï¼Œ2-åˆ†æ•°ï¼Œ3-ç›®æ ‡KBæ•°
        type: "image/jpeg",         // ç”Ÿæˆå›¾ç‰‡çš„æ ¼å¼ï¼Œå¯ä¸º image/jpeg æˆ– image/png
        quality: 0.7,               // ç”Ÿæˆå›¾ç‰‡çš„è´¨é‡ï¼Œä¸åŽ‹ç¼©ä¸º1ï¼ˆé’ˆå¯¹jpgæ ¼å¼ï¼‰
        capture: false,              // æ˜¯å¦ä¸ºç§»åŠ¨ç«¯æ·»åŠ è°ƒç”¨æ‘„åƒå¤´æ‹æ‘„çš„åŠŸèƒ½
        before: new Function(),     // åœ¨ç”Ÿæˆç¼©ç•¥å›¾å‰çš„é¢„å¤„ç†ï¼Œå°†ä¼ å…¥æœªå¤„ç†çš„å›¾ç‰‡æ–‡ä»¶å¯¹è±¡
        callback: new Function()    // å¤„ç†åŽç»base64ç¼–ç çš„ç¼©ç•¥å›¾ä¿¡æ¯å°†ä¼ é€’ç»™æ­¤å›žè°ƒå‡½æ•°
    };
    let opt = $.extend({}, defaults, options || {});

    if(opt.capture) {
        this.attr({
            accept : "image/*",
            capture : "true"
        });
    }

    this.on('change', function() {
        if(this.value==="") return;
        let file = this.files[0];
        if($.isFunction(options)) opt = options();
        getOrientation(file, function(orientation){
            let reader, blob;
            if(typeof(FileReader)==='function') {
                reader  = new FileReader();
            } else {
                let URL = window.URL || window.webkitURL || window.mozURL || window.msURL;
                blob = URL.createObjectURL(file);
            }
            if($.isFunction(opt.before)) opt.before(file);
            let img = new Image();
            img.onload = function() {
                let para = getOpt(this.width, this.height, file.size);
                let w = para.width;
                let h = para.height;
                let canvas = document.createElement("canvas");
                let ctx = canvas.getContext('2d');
                if(orientation<6) {
                    canvas.width = w;
                    canvas.height = h;
                } else {
                    canvas.width = h;
                    canvas.height = w;
                }
                switch(orientation) {
                    case 2:
                        // horizontal flip
                        ctx.translate(w, 0);
                        ctx.scale(-1, 1);
                        break;
                    case 3:
                        // 180 rotate left
                        ctx.translate(w, h);
                        ctx.rotate(Math.PI);
                        break;
                    case 4:
                        // vertical flip
                        ctx.translate(0, h);
                        ctx.scale(1, -1);
                        break;
                    case 5:
                        // vertical flip + 90 rotate right
                        ctx.rotate(0.5 * Math.PI);
                        ctx.scale(1, -1);
                        break;
                    case 6:
                        // 90 rotate right
                        ctx.rotate(0.5 * Math.PI);
                        ctx.translate(0, -h);
                        break;
                    case 7:
                        // horizontal flip + 90 rotate right
                        ctx.rotate(0.5 * Math.PI);
                        ctx.translate(w, -h);
                        ctx.scale(-1, 1);
                        break;
                    case 8:
                        // 90 rotate left
                        ctx.rotate(-0.5 * Math.PI);
                        ctx.translate(-w, 0);
                        break;
                    default:
                        console.log(orientation);
                }
                ctx.drawImage(this, 0, 0, w, h);
                this.onload = null;

                let result = '';
                if( navigator.userAgent.match(/iphone/i) ) {
                    let mpImg = new MegaPixImage(img);
                    mpImg.render(canvas, { maxWidth: w, maxHeight: h, quality: opt.quality || 0.8});
                    result = canvas.toDataURL(opt.type, opt.quality);
                } else if( navigator.userAgent.match(/Android/i) ) {
                    opt.type = "image/jpeg";
                    let encoder = new JPEGEncoder();
                    result = encoder.encode(ctx.getImageData(0,0,w,h), opt.quality * 100);
                } else {
                    result = canvas.toDataURL(opt.type, opt.quality);
                }
                if($.isFunction(opt.callback)) opt.callback(result);
            }

            if(!!reader) {
                reader.addEventListener("load", function () {
                    img.src = reader.result;
                }, false);
                reader.readAsDataURL(file);
            } else {
                img.src = blob;
            }
        });
    });

    let getOpt = function(width, height, size) {
        let result = {};
        switch(opt.mode) {
            case 0:
                result.rate = opt.val/width;
                result.width = opt.val;
                result.height = height * result.rate;
                break;
            case 1:
                result.rate = opt.val;
                result.width = width * opt.val;
                result.height = height * opt.val;
                break;
            case 2:
                opt.val *= 1024;
                result.rate = Math.sqrt(size / opt.val);
                result.width = Math.ceil(width / result.rate);
                result.height = Math.ceil(height / result.rate);
                break;
        }
        opt = $.extend(opt, result);
        return result;
    }

    let getOrientation = function (file, callback) {
        let reader = new FileReader();
        reader.onload = function(e) {
            let view = new DataView(e.target.result);
            if (view.getUint16(0, false) !== 0xFFD8) {
                return callback(-2);
            }
            let length = view.byteLength, offset = 2;
            while (offset < length) {
                if (view.getUint16(offset+2, false) <= 8) return callback(-1);
                let marker = view.getUint16(offset, false);
                offset += 2;
                if (marker === 0xFFE1) {
                    if (view.getUint32(offset += 2, false) !== 0x45786966) {
                        return callback(-1);
                    }
                    let little = view.getUint16(offset += 6, false) === 0x4949;
                    offset += view.getUint32(offset + 4, little);
                    let tags = view.getUint16(offset, little);
                    offset += 2;
                    for (let i = 0; i < tags; i++) {
                        if (view.getUint16(offset + (i * 12), little) === 0x0112) {
                            return callback(view.getUint16(offset + (i * 12) + 8, little));
                        }
                    }
                } else if ((marker & 0xFF00) !== 0xFF00) {
                    break;
                } else {
                    offset += view.getUint16(offset, false);
                }
            }
            return callback(-1);
        };
        reader.readAsArrayBuffer(file);
    }
};