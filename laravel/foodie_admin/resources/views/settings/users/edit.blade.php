@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">
            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{trans('lang.user_plural')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{!! route('users') !!}">{{trans('lang.user_plural')}}</a></li>
                    <li class="breadcrumb-item active">{{trans('lang.user_edit')}}</li>
                </ol>
            </div>

        </div>
        <div>
            <div class="card-body">

                <div id="data-table_processing" class="dataTables_processing panel panel-default"
                     style="display: none;">{{trans('lang.processing')}}</div>

                <div class="row daes-top-sec mb-3">

                    <div class="col-lg-6 col-md-6">
                        <a href="{{route('orders','userId='.$id)}}">

                            <div class="card">

                                <div class="flex-row">

                                    <div class="p-10 bg-info col-md-12 text-center">

                                        <h3 class="text-white box m-b-0"><i class="mdi mdi-cart"></i></h3></div>

                                    <div class="align-self-center pt-3 col-md-12 text-center">

                                        <h3 class="m-b-0 text-info" id="total_orders">0</h3>

                                        <h5 class="text-muted m-b-0">{{trans('lang.dashboard_total_orders')}}</h5>

                                    </div>

                                </div>

                            </div>
                        </a>
                    </div>

                    <div class="col-lg-6 col-md-6">
                        <a href="{{route('users.walletstransaction',$id)}}">
                            <div class="card">

                                <div class="flex-row">

                                    <div class="p-10 bg-info col-md-12 text-center">

                                        <h3 class="text-white box m-b-0"><i class="mdi mdi-bank"></i></h3></div>

                                    <div class="align-self-center pt-3 col-md-12 text-center">

                                        <h3 class="m-b-0 text-info" id="wallet_amount">0</h3>

                                        <h5 class="text-muted m-b-0">{{trans('lang.wallet_Balance')}}</h5>

                                    </div>

                                </div>

                            </div>
                        </a>
                    </div>

                </div>

                <div class="error_top"></div>
                <div class="row restaurant_payout_create">
                    <div class="restaurant_payout_create-inner">

                        <fieldset>
                            <legend>{{trans('lang.user_edit')}}</legend>
                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.first_name')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control user_first_name"
                                           onkeypress="return chkAlphabets(event,'error')">
                                    <div id="error" class="err"></div>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.user_first_name_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.last_name')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control user_last_name"
                                           onkeypress="return chkAlphabets(event,'error1')">
                                    <div id="error1" class="err"></div>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.user_last_name_help") }}
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.email')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control user_email">
                                    <div class="form-text text-muted">
                                        {{ trans("lang.user_email_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.user_phone')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control user_phone"
                                           onkeypress="return chkAlphabets2(event,'error2')">
                                    <div id="error2" class="err"></div>
                                    <div class="form-text text-muted w-50">
                                        {{ trans("lang.user_phone_help") }}
                                    </div>
                                </div>

                            </div>

                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.restaurant_image')}}</label>
                                <input type="file" onChange="handleFileSelect(event)" class="col-7">
                                <div class="placeholder_img_thumb user_image"></div>
                                <div id="uploding_image"></div>
                            </div>
                        </fieldset>

                        <fieldset>
                            <legend>{{trans('user')}} {{trans('lang.active_deactive')}}</legend>
                            <div class="form-group row width-100">

                                <div class="form-check">
                                    <input type="checkbox" class="user_active" id="user_active">
                                    <label class="col-3 control-label"
                                           for="user_active">{{trans('lang.active')}}</label>
                                </div>

                                <div class="form-check">
                                    <input type="checkbox" id="reset_password">
                                    <label class="col-3 control-label" for="reset_password">{{trans('lang.reset_password')}}</label>
                                    <div class="form-text text-muted w-100">
                                        {{ trans("lang.note_reset_password_email") }}
                                    </div>
                                </div>
                                <div class="form-button" style="margin-top: 16px;margin-left: 20px;">
                                    <button type="button" class="btn btn-primary"
                                            id="send_mail">{{trans('lang.send_mail')}}</button>
                                </div>

                            </div>
                        </fieldset>
                    </div>
                </div>
            </div>
            <div class="form-group col-12 text-center btm-btn">
                <button type="button" class="btn btn-primary  save_user_btn"><i
                            class="fa fa-save"></i> {{ trans('lang.save')}}</button>
                <a href="{!! route('users') !!}" class="btn btn-default"><i
                            class="fa fa-undo"></i>{{ trans('lang.cancel')}}</a>
            </div>
        </div>
    </div>

@endsection

@section('scripts')

    <script>

        var id = "<?php echo $id;?>";
        var database = firebase.firestore();
        var ref = database.collection('users').where("id", "==", id);
        var currentCurrency = '';
        var currencyAtRight = false;
        var decimal_degits = 0;

        var photo = "";
        var storageRef = firebase.storage().ref('images');
        var storage = firebase.storage();
        var fileName = "";
        var userImageFile = '';

        var placeholderImage = '';
        var placeholder = database.collection('settings').doc('placeHolderImage');

        placeholder.get().then(async function (snapshotsimage) {
            var placeholderImageData = snapshotsimage.data();
            placeholderImage = placeholderImageData.image;
        })
        var refCurrency = database.collection('currencies').where('isActive', '==', true);
        var append_list = '';

        refCurrency.get().then(async function (snapshots) {
            var currencyData = snapshots.docs[0].data();
            currentCurrency = currencyData.symbol;
            currencyAtRight = currencyData.symbolAtRight;

            if (currencyData.decimal_degits) {
                decimal_degits = currencyData.decimal_degits;
            }
        });

        $("#send_mail").click(function () {
            if ($("#reset_password").is(":checked")) {
                var email = $(".user_email").val();
                firebase.auth().sendPasswordResetEmail(email)
                    .then((res) => {
                        alert('{{trans("lang.mail_sent")}}');
                    })
                    .catch((error) => {
                        console.log('Error password reset: ', error);
                    });
            }else{
                alert('{{trans("lang.mail_send_error")}}');
            }
        });
        $(document).ready(function () {

            jQuery("#data-table_processing").show();

            ref.get().then(async function (snapshots) {

                var user = snapshots.docs[0].data();
                $(".user_first_name").val(user.firstName);
                $(".user_last_name").val(user.lastName);
                $(".user_email").val(user.email);
                $(".user_phone").val(user.phoneNumber);

                //photo = user.profilePictureURL;
                if (user.profilePictureURL != '') {
                    photo = user.profilePictureURL;
                    userImageFile = user.profilePictureURL;

                    $(".user_image").append('<img class="rounded" style="width:50px" src="' + photo + '" alt="image">');
                } else {

                    $(".user_image").append('<img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image">');
                }

                if (user.active) {
                    $(".user_active").prop('checked', true);
                }

                if (currencyAtRight) {
                    var wallet_amount = parseFloat(user.wallet_amount).toFixed(decimal_degits) + currentCurrency;
                } else {
                    var wallet_amount = currentCurrency + parseFloat(user.wallet_amount).toFixed(decimal_degits);
                }


                if (wallet_amount != undefined) {

                    $("#wallet_amount").text(wallet_amount);
                }
                if (isNaN(user.wallet_amount)) {
                    if (currencyAtRight) {
                        var wallet_amount = parseFloat(0).toFixed(decimal_degits) + currentCurrency;
                    } else {
                        var wallet_amount = currentCurrency + parseFloat(0).toFixed(decimal_degits);
                    }
                    $("#wallet_amount").text(wallet_amount);
                }

                var orderRef = database.collection('restaurant_orders').where("authorID", "==", id);
                orderRef.get().then(async function (snapshotsorder) {

                    var orders = snapshotsorder.size;

                    $("#total_orders").text(orders);

                });

                jQuery("#data-table_processing").hide();
            })

            $(".save_user_btn").click(function () {

                var userFirstName = $(".user_first_name").val();
                var userLastName = $(".user_last_name").val();
                var email = $(".user_email").val();
                var userPhone = $(".user_phone").val();
                var active = $(".user_active").is(":checked");
                var password = $(".user_password").val();
                var user_name = userFirstName + " " + userLastName;

                if (userFirstName == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.user_firstname_error')}}</p>");
                    window.scrollTo(0, 0);
                } else if (userPhone == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.user_phone_error')}}</p>");
                    window.scrollTo(0, 0);
                } 
                else {
                    jQuery("#data-table_processing").show();

                    storeImageData().then(IMG => {
                    database.collection('users').doc(id).update({
                        'firstName': userFirstName,
                        'lastName': userLastName,
                        'email': email,
                        'phoneNumber': userPhone,
                        'isActive': active,
                        'profilePictureURL': IMG,
                        'role': 'customer',
                        'active': active
                    }).then(function (result) {
                        jQuery("#data-table_processing").hide();

                        window.location.href = '{{ route("users")}}';

                    });
                    }).catch(err => {
                        jQuery("#data-table_processing").hide();
                        $(".error_top").show();
                        $(".error_top").html("");
                        $(".error_top").append("<p>" + err + "</p>");
                        window.scrollTo(0, 0);
                    });

                }

            })


        })
    async function storeImageData() {
                var newPhoto = '';
                try {
                    if (userImageFile != "" && photo != userImageFile) {
                        var userOldImageUrlRef = await storage.refFromURL(userImageFile);
                        console.log(userOldImageUrlRef);
                        /*await userOldImageUrlRef.delete().then(() => {
                            console.log("Old file deleted!")
                        }).catch((error) => {
                            console.log("ERR File delete ===", error);
                        });*/
                    }
                    if (photo != userImageFile) {
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

        function handleFileSelect(evt) {
            var f = evt.target.files[0];
            var reader = new FileReader();

            reader.onload = (function (theFile) {
                return function (e) {

                    var filePayload = e.target.result;
                    var val = f.name;
                    var ext = val.split('.')[1];
                    var docName = val.split('fakepath')[1];
                    var filename = (f.name).replace(/C:\\fakepath\\/i, '')

                    var timestamp = Number(new Date());
                    var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                    photo = filePayload;
                    fileName = filename;
                    $(".user_image").empty();
                    $(".user_image").append('<img class="rounded" style="width:50px" src="' + photo + '" alt="image">');

                   /* var uploadTask = storageRef.child(filename).put(theFile);
                    console.log(uploadTask);
                    uploadTask.on('state_changed', function (snapshot) {
                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        console.log('Upload is ' + progress + '% done');
                        jQuery("#uploding_image").text("Image is uploading...");
                    }, function (error) {
                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            jQuery("#uploding_image").text("Upload is completed");
                            photo = downloadURL;
                            $(".user_image").empty();
                            $(".user_image").append('<img class="rounded" style="width:50px" src="' + photo + '" alt="image">');


                        });
                    });*/

                };
            })(f);
            reader.readAsDataURL(f);
        }

        function chkAlphabets(event, msg) {
            if (!(event.which >= 97 && event.which <= 122) && !(event.which >= 65 && event.which <= 90)) {
                document.getElementById(msg).innerHTML = "Accept only Alphabets";
                return false;
            } else {
                document.getElementById(msg).innerHTML = "";
                return true;
            }
        }

        function chkAlphabets2(event, msg) {
            if (!(event.which >= 48 && event.which <= 57)
            ) {
                document.getElementById(msg).innerHTML = "Accept only Number";
                return false;
            } else {
                document.getElementById(msg).innerHTML = "";
                return true;
            }
        }

        function chkAlphabets3(event, msg) {
            if (!((event.which >= 48 && event.which <= 57) || (event.which >= 97 && event.which <= 122))) {
                document.getElementById(msg).innerHTML = "Special characters not accepted ";
                return false;
            } else {
                document.getElementById(msg).innerHTML = "";
                return true;
            }
        }

    </script>
@endsection
