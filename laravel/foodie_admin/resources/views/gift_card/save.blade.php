@extends('layouts.app')

@section('content')
<div class="page-wrapper">
    <div class="row page-titles">
        <div class="col-md-5 align-self-center">
            @if($id=='')
            <h3 class="text-themecolor">{{trans('lang.create_gift_card')}}</h3>
            @else
            <h3 class="text-themecolor">{{trans('lang.edit_gift_card')}}</h3>
            @endif

        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item"><a href="{{ url('gift-card') }}">{{trans('lang.gift_card')}}</a>
                </li>

                @if($id=='')
                <li class="breadcrumb-item active">{{trans('lang.create_gift_card')}}</li>
                @else
                <li class="breadcrumb-item active">{{trans('lang.edit_gift_card')}}</li>
                @endif


            </ol>
        </div>

    </div>
    <div>

        <div class="card-body">

            <div id="data-table_processing" class="dataTables_processing panel panel-default" style="display: none;">
                {{trans('lang.processing')}}
            </div>

            <div class="error_top" style="display:none"></div>

            <div class="success_top" style="display:none"></div>

            <div class="row restaurant_payout_create">

                <div class="restaurant_payout_create-inner">

                    <fieldset>
                        <legend>{{trans('lang.gift_card')}}</legend>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.title')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control" id="title" >
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.message')}}</label>
                            <div class="col-7">
                            <textarea rows="8" class="form-control col-7" name="message" id="message"></textarea>
                        </div>
                        </div>
                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.image')}}</label>
                            <div class="col-7">
                                <input type="file" class="form-control" id="gift_card_image">
                                 <div class="placeholder_img_thumb gift_card_image"></div>
                                 <div id="uploding_image"></div>

                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.expiry_day')}}</label>
                            <div class="col-7">
                                <input type="number" class="form-control" id="expiry">
                            </div>
                        </div>

                        <div class="form-group row width-100">

                            <div class="form-check width-100">

                                <input type="checkbox" id="status">

                                <label class="col-3 control-label"
                                    for="status">{{trans('lang.status')}}</label>

                            </div>

                        </div>


                    </fieldset>
                </div>

            </div>

        </div>
        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary save_gift_card"><i class="fa fa-save"></i> {{
                trans('lang.save')}}
            </button>
            <a href="{{url('gift-card')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{
                trans('lang.cancel')}}</a>
        </div>

    </div>

    @endsection

    @section('scripts')

    <script>

        var requestId = "<?php echo $id; ?>";
        var database = firebase.firestore();
        var createdAt = firebase.firestore.FieldValue.serverTimestamp();
        var id = (requestId == '') ? database.collection("tmp").doc().id : requestId;
        var photo='';
        var fileName='';  
        var oldImagePath='';      
        var pagesize = 20;
        var start = '';
        var storageRef = firebase.storage().ref('images');
        var storage = firebase.storage();
        var placeholderImage='';
        var placeholder = database.collection('settings').doc('placeHolderImage');
         
        placeholder.get().then(async function (snapshotsimage) {
                var placeholderImageData = snapshotsimage.data();
                placeholderImage = placeholderImageData.image;
            })
        

        $(document).ready(function () {
            if (requestId != '') {
                var ref = database.collection('gift_cards').where('id', '==', id);
                jQuery("#data-table_processing").show();
                ref.get().then(async function (snapshots) {
                    if (snapshots.docs.length) {
                        var data = snapshots.docs[0].data();
                        $("#title").val(data.title);
                        $('#message').val(data.message);
                        if (data.isEnable) {
                            $("#status").prop('checked', true);
                        }
                        $('#expiry').val(data.expiryDay);
                        if (data.image && data.image!='') {
                            photo = data.image;
                            oldImagePath = data.image;
                            $(".gift_card_image").html('<span class="image-item"><img class="rounded" style="width:50px" src="' + data.image + '" alt="image" id="img"></span>');
                        } else {

                            $(".gift_card_image").html('<span class="image-item" ><img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image"></span>');
                        }


                    }
                    jQuery("#data-table_processing").hide();

                });
            }
        });

        $(".save_gift_card").click(async function () {

            $(".success_top").hide();
            $(".error_top").hide();
            var title = $("#title").val();
            var message = $('#message').val();
            var expiryDay = $('#expiry').val();
            var status = $("#status").is(":checked");
            var giftCardimg = $('#img').attr('src');

            if (title == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.please_enter_title')}}</p>");
                window.scrollTo(0, 0);
                return false;
            } else if (message == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.please_enter_message')}}</p>");
                window.scrollTo(0, 0);
                return false;
            
            } else if(!giftCardimg){
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.please_enter_image')}}</p>");
                window.scrollTo(0, 0);
                return false;

            }
             else if (expiryDay < 0) {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.expiry_day_in_positive_no')}}</p>");
                window.scrollTo(0, 0);
                return false;
            } 

            else {
                jQuery("#data-table_processing").show();
                storeImageData().then(IMG => {
                requestId == '' ? (database.collection('gift_cards').doc(id).set({
                    'id': id,
                    'title': title,
                    'message': message,
                    'expiryDay': expiryDay,
                    'isEnable': status,
                    'image':IMG,
                    'createdAt':createdAt
                }).then(function (result) {
                    jQuery("#data-table_processing").hide();
                    $(".success_top").show();
                    $(".success_top").html("");
                    window.scrollTo(0, 0);
                    window.location.href = '{{ route("gift-card.index")}}';
                }).catch(function (error) {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + error + "</p>");
                })) :
                    (database.collection('gift_cards').doc(id).update({
                    'title': title,
                    'message': message,
                    'expiryDay': expiryDay,
                    'isEnable': status,
                    'image':IMG
                    }).then(function (result) {
                        jQuery("#data-table_processing").hide();
                        $(".success_top").show();
                        $(".success_top").html("");
                        window.scrollTo(0, 0);
                        window.location.href = '{{ route("gift-card.index")}}';
                    }).catch(function (error) {
                        $(".error_top").show();
                        $(".error_top").html("");
                        $(".error_top").append("<p>" + error + "</p>");
                    }));
                }).catch(err => {
                jQuery("#overlay").hide();
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>" + err + "</p>");
                window.scrollTo(0, 0);
            });


            }

        });
    $("#gift_card_image").resizeImg({

            callback: function (base64str) {

                var val = $('#gift_card_image').val().toLowerCase();
                var ext = val.split('.')[1];
                var docName = val.split('fakepath')[1];
                var filename = $('#gift_card_image').val().replace(/C:\\fakepath\\/i, '')
                var timestamp = Number(new Date());
                var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                photo=base64str;
                fileName=filename;
                $(".gift_card_image").html('<span class="image-item"><img class="rounded" style="width:50px" src="' + base64str + '" alt="image" id="img"></span>');
                $("#gift_card_image").val('');
            }
        });

        async function storeImageData() {
            var newPhoto = '';
            try {
                if (oldImagePath != "" && photo != oldImagePath) {
                    var oldImageRef = await storage.refFromURL(oldImagePath);
                   /* await oldImageRef.delete().then(() => {
                        console.log("Old file deleted!")
                    }).catch((error) => {
                        console.log("ERR File delete ===", error);
                    });*/
                }
                if (photo != oldImagePath) {
                    photo = photo.replace(/^data:image\/[a-z]+;base64,/, "")
                    var uploadTask = await storageRef.child(fileName).putString(photo, 'base64', { contentType: 'image/jpg' });
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    newPhoto = downloadURL;
                    photo = downloadURL;
                } else {
                    newPhoto = photo;
                }
            } catch (error) {
                console.log("ERR ===", error);
            }
            return newPhoto;
        }


    </script>

    @endsection