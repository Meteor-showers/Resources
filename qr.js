$(function(){function qr(text){var options={render:'canvas',size:300,ecLevel:'Q',fill:'#233',background:null,text:text,label:'xkzs',fontname:'sans',fontcolor:'#233',quiet:0,mode:2};$("#qrcode").empty().qrcode(options);}$("#generate").on("click",function(){var v=$("#text").val();if(v===""){$("#qrcode").html('输入内容呀。。。没有内容生成个蛋啊。。。。');}else{qr(v);}});$("#text").on("input",function(){if($(this).val()===""){$("#qrcode").empty();}});function getParameterByName(name,url){if(!url)url=window.location.href;name=name.replace(/[\[\]]/g,'\\$&');var regex=new RegExp('[?&]'+name+'(=([^&#]*)|&|#|$)'),results=regex.exec(url);if(!results)return null;if(!results[2])return'';return decodeURIComponent(results[2].replace(/\+/g,' '));}var initialText=getParameterByName('text');if(initialText){$("#text").val(initialText);qr(initialText);}});