@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">

            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{trans('lang.app_setting_global')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item active">{{trans('lang.app_setting_global')}}</li>
                </ol>
            </div>
        </div>

        <div class="card-body">
            <div id="data-table_processing" class="dataTables_processing panel panel-default"
                 style="display: none;">{{trans('lang.processing')}}</div>
            <div class="error_top" style="display:none"></div>
            <div class="row restaurant_payout_create">
                <div class="restaurant_payout_create-inner">
                    <fieldset>
                        <legend><i class="mr-3 mdi mdi-settings"></i>{{trans('lang.app_setting_global')}}</legend>

                        <div class="form-group row width-100">
                            <label class="col-5 control-label">{{trans('lang.app_setting_app_name')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control application_name">
                                <div class="form-text text-muted">
                                    {{ trans("lang.app_setting_app_name_help") }}
                                </div>
                            </div>
                        </div>
                        <div class="form-group row width-100">
                            <label class="col-5 control-label">{{trans('lang.app_setting_meta_title')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control meta_title">
                                <div class="form-text text-muted">
                                    {{ trans("lang.app_setting_meta_title_help") }}
                                </div>
                            </div>
                        </div>
                        <div class="form-group row width-50">
                            <label class="col-3 control-label">{{trans('lang.upload_app_logo')}}</label>
                            <input type="file" class="col-7" onChange="handleFileSelect(event)">
                            <div id="uploding_image"></div>
                            <div class="logo_img_thumb"></div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.menu_placeholder_image')}}</label>
                            <input type="file" class="col-7" onChange="handleFileSelectplaceholder(event)">
                            <div id="uploading_placeholder"></div>
                            <div class="placeholder_img_thumb">
                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-3 control-label">{{trans('lang.upload_favicon')}}</label>
                            <input type="file" class="col-7" onChange="handleFileSelectFavicon(event)">
                            <div id="uploding_favicon"></div>
                            <div class="favicon_img_thumb"></div>
                        </div>
                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.website_color_settings')}}</label>
                            <input type="color" class="ml-3" name="website_color" id="website_color">
                        </div>
                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.admin_panel_color_settings')}}</label>
                            <input type="color" class="ml-3" name="admin_color" id="admin_color">
                        </div>
                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.store_panel_color_settings')}}</label>
                            <input type="color" class="ml-3" name="store_color" id="store_color">
                        </div>

                        <div class="form-group width-100 choose-theme">
                            <label class="col-12 control-label">{{trans('lang.app_homepage_theme')}}</label>
                            <div class="col-12">
                                <div class="select-theme-radio">
                                    <label class="form-check-label" for="app_homepage_theme_1">
                                        <input type="radio" class="btn-check" name="app_homepage_theme" id="app_homepage_theme_1" value="theme_1">
                                        <img src="{{url('images/app_homepage_theme_1.png')}}" height="150">
                                    </label>
                                    <label class="form-check-label" for="app_homepage_theme_2">
                                        <input type="radio" class="btn-check" name="app_homepage_theme" id="app_homepage_theme_2" value="theme_2">
                                        <img src="{{url('images/app_homepage_theme_2.png')}}" height="150">    
                                    </label>
                                </div>
                            </div>
                        </div>
                        
                    </fieldset>
                    <fieldset>
                        <legend>{{trans('lang.google_map_api_key_title')}}</legend>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.google_map_api_key')}}</label>
                            <div class="col-7">
                                <input type="password" class="form-control address_line1" name="map_key"
                                       id="map_key">
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 fa fa-solid fa-address-book"></i>{{trans('lang.contact_us')}}</legend>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.contact_us_address')}}</label>
                            <div class="col-7">
                                <textarea class="form-control contact_us_address" rows="3"></textarea>
                                <div class="form-text text-muted">
                                    {{ trans("lang.contact_us_address_help") }}
                                </div>
                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.contact_us_email')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control contact_us_email">
                                <div class="form-text text-muted">
                                    {{ trans("lang.contact_us_email_help") }}
                                </div>
                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.contact_us_phone')}}</label>
                            <div class="col-7">
                                <input type="number" class="form-control contact_us_phone">
                                <div class="form-text text-muted">
                                    {{ trans("lang.contact_us_phone_help") }}
                                </div>
                            </div>
                        </div>

                    </fieldset>

                    <fieldset>
                        <legend>{{trans('lang.map_redirection')}}</legend>
                        <div class="form-group row width-100">
                            <label class="col-4 control-label">{{trans('lang.select_map_type')}}</label>
                            <div class="col-7">
                                <select name="map_type" id="map_type" class="form-control map_type">
                                    <option value="">{{trans("lang.select_type")}}</option>
                                    <option value="google">{{trans("lang.google_map")}}</option>
                                    <option value="googleGo">{{trans("lang.google_go_map")}}</option>
                                    <option value="waze">{{trans("lang.waze_map")}}</option>
                                    <option value="mapswithme">{{trans("lang.mapswithme_map")}}</option>
                                    <option value="yandexNavi">{{trans("lang.vandexnavi_map")}}</option>
                                    <option value="yandexMaps">{{trans("lang.vandex_map")}}</option>
                                    <option value="inappmap">{{trans("lang.inapp_map")}}</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group row width-100">
                            <label class="col-4 control-label">{{trans('lang.driver_location_update')}}</label>
                            <div class="col-7">
                                <input name="radius" id="driver_location_update" class="form-control">
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <div class="form-check width-100">
                                <input type="checkbox" class="form-check-inline" id="single_order_receive">
                                <label class="col-5 control-label" for="single_order_receive">{{ trans('lang.single_order_receive')}}</label>
                            </div>    
                        </div>
                        
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 mdi mdi-cash-100"></i>{{trans('lang.wallet_settings')}}</legend>
                        <div class="form-group row width-100">
                            <label class="col-4 control-label">{{ trans('lang.minimum_deposit_amount')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control minimum_deposit_amount">
                                </div>
                            </div>
                        </div>
                        <div class="form-group row width-100">
                            <label class="col-4 control-label">{{ trans('lang.minimum_withdrawal_amount')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control minimum_withdrawal_amount">
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 mdi mdi-share"></i>{{trans('lang.referral_settings')}}</legend>
                        <div class="form-group row width-100">
                            <label class="col-4 control-label">{{ trans('lang.referral_amount')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control referral_amount">
                                    <span class="currentCurrency"></span>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.referral_amount_help") }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 mdi mdi-shopping"></i>{{trans('lang.restaurant_settings')}}</legend>
                        <div class="form-group row width-100">
                            <div class="form-check width-100">
                                <input type="checkbox" class="form-check-inline" id="restaurant_can_upload_story">
                                <label class="col-5 control-label"
                                       for="restaurant_can_upload_story">{{ trans('lang.restaurant_can_upload_story')}}</label>
                                <input type="checkbox" class="form-check-inline" id="auto_approve_restaurant">
                                <label class="col-5 control-label"
                                       for="auto_approve_restaurant">{{ trans('lang.auto_approve_restaurant')}}</label>
                            </div>
                        </div>
                        <div class="form-group row width-50" id="story_upload_time_div" style="display:none;">
                            <label class="col-5 control-label">{{trans('lang.story_upload_time')}}</label>
                            <div class="col-7">
                                <input type="number" class="form-control" id="story_upload_time" value="30" min="0">
                                <div class="form-text text-muted">
                                    {{ trans("lang.story_upload_time_help") }}
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend>{{trans('lang.email_setting')}}</legend>


                        <div class="form-group row width-50">

                            <label class="col-3 control-label">{{trans('lang.smtp')}} {{trans('lang.from_name')}}</label>

                            <div class="col-7">

                                <input type="text" class="form-control from_name">

                            </div>

                        </div>

                        <div class="form-group row width-50">

                            <label class="col-3 control-label">{{trans('lang.smtp')}} {{trans('lang.host')}}</label>

                            <div class="col-7">

                                <input type="text" class="form-control host">

                            </div>

                        </div>

                        <div class="form-group row width-50">

                            <label class="col-3 control-label">{{trans('lang.smtp')}} {{trans('lang.port')}}</label>

                            <div class="col-7">

                                <input type="text" class="form-control port">

                            </div>

                        </div>

                        <div class="form-group row width-50">

                            <label class="col-3 control-label">{{trans('lang.smtp_user_name')}}</label>

                            <div class="col-7">

                                <input type="text" class="form-control user_name">

                            </div>

                        </div>

                        <div class="form-group row width-50">

                            <label class="col-3 control-label">{{trans('lang.smtp')}} {{trans('lang.password')}}</label>

                            <div class="col-7">

                                <input type="password" class="form-control password">

                            </div>

                        </div>

                    </fieldset>
                    <fieldset>
                        <legend><i class="mr-3 fa fa-solid fa fa-android"></i>{{trans('lang.version')}}</legend>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.app_version')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control app_version">

                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-5 control-label">{{trans('lang.web_version')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control" id="web_version">

                            </div>
                        </div>

                    </fieldset>
                </div>
            </div>
        </div>

        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary save_global_settings_btn"><i
                        class="fa fa-save"></i> {{trans('lang.save')}}</button>
            <a href="{{url('/dashboard')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}
            </a>
        </div>
    </div>

    <div class="modal fade" id="themeModal" tabindex="-1" role="dialog" aria-labelledby="themeModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document" style="max-width: 50%;">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="form-group">
                        <img id="themeImage" src="" width="630">
                    </div>
                </div>
            </div>
        </div>
    </div>

@endsection

@section('scripts')

    <script>

        var database = firebase.firestore();
        var ref = database.collection('settings').doc("globalSettings");
        var mapKey = database.collection('settings').doc("googleMapKey");
        var refPlaceholderImage = database.collection('settings').doc("placeHolderImage");
        var contactUs = database.collection('settings').doc("ContactUs");
        var version = database.collection('settings').doc("Version");
        var restaurant = database.collection('settings').doc("restaurant");
        var story = database.collection('settings').doc("story");
        var DriverNearByRef = database.collection('settings').doc("DriverNearBy");
        var referralAmountRef = database.collection('settings').doc("referral_amount");
        var refEmailSetting = database.collection('settings').doc("emailSetting");
        var homepagethemeRef = database.collection('settings').doc("home_page_theme");
        var theme_1_url = '{!! url("images/app_homepage_theme_1.png"); !!}';
        var theme_2_url = '{!! url("images/app_homepage_theme_2.png"); !!}';

        var photo = "";
        var placeholderphoto = '';
        var favicon="";
        var appLogoImagePath = '';
        var appFavIconImagePath = '';
        var placeholderImagePath = '';
        var logoFileName = '';
        var favIconFileName = '';
        var placeholderFileName='';
        var storageRef = firebase.storage().ref('images');
        var storage = firebase.storage();

        var refCurrency = database.collection('currencies').where('isActive', '==', true);
        refCurrency.get().then(async function (snapshots) {
            var currencyData = snapshots.docs[0].data();
            $(".currentCurrency").text(currencyData.symbol);
        });

        $(document).ready(function () {

            jQuery("#data-table_processing").show();

            ref.get().then(async function (snapshots) {

                var globalSettings = snapshots.data();

                if (globalSettings == undefined) {
                    database.collection('settings').doc('globalSettings').set({});
                }

                try {
                    $(".application_name").val(globalSettings.applicationName);
                    $(".meta_title").val(globalSettings.meta_title)
                    $("#website_color").val(globalSettings.website_color);
                    $("#admin_color").val(globalSettings.admin_panel_color);
                    $("#store_color").val(globalSettings.store_panel_color);

                    if(globalSettings.appLogo!="" && globalSettings.appLogo!=null){
                        photo = globalSettings.appLogo;
                        appLogoImagePath=globalSettings.appLogo;
                        $(".logo_img_thumb").append('<img class="rounded" style="width:50px" src="' + photo + '" alt="image">');
                    }

                    if(globalSettings.favicon!="" && globalSettings.favicon!=null){
                        favicon = globalSettings.favicon;
                        appFavIconImagePath=globalSettings.favicon;
                        $(".favicon_img_thumb").append('<img class="rounded" style="width:50px" src="' + favicon + '" alt="image">');

                    }


                } catch (error) {

                }

                jQuery("#data-table_processing").hide();
            })

            refPlaceholderImage.get().then(async function (snapshots) {
                var placeholderImage = snapshots.data();
                jQuery("#data-table_processing").hide();
                if(placeholderImage.image!="" && placeholderImage.image!=null){
                    placeholderphoto = placeholderImage.image;
                    placeholderImagePath=placeholderImage.image;
                    $(".placeholder_img_thumb").append('<img class="rounded" style="width:50px" src="' + placeholderphoto + '" alt="image">');

                }
            })

            restaurant.get().then(async function (snapshots) {
                var restaurantdata = snapshots.data();
                if (restaurantdata == undefined) {
                    database.collection('settings').doc('restaurant').set({});
                }
                try {
                    if (restaurantdata.auto_approve_restaurant) {
                        $("#auto_approve_restaurant").prop('checked', true);
                    }
                } catch (error) {

                }
                jQuery("#data-table_processing").hide();
            })

            story.get().then(async function (snapshots) {
                var story_data = snapshots.data();

                if (story_data == undefined) {
                    database.collection('settings').doc('story').set({});
                }
                try {
                    if (story_data.isEnabled) {
                        $("#restaurant_can_upload_story").prop('checked', true);
                        $("#story_upload_time_div").show();
                    }
                    $("#story_upload_time").val(story_data.videoDuration);
                } catch (error) {

                }
            });

            version.get().then(async function (snapshots) {
                var version_data = snapshots.data();

                if (version_data == undefined) {
                    database.collection('settings').doc('Version').set({});
                }
                try {
                    $('.app_version').val(version_data.app_version);
                    $('#web_version').val(version_data.web_version);

                } catch (error) {

                }

            });

            contactUs.get().then(async function (snapshots) {
                var contactUsData = snapshots.data();

                if (contactUsData == undefined) {
                    database.collection('settings').doc('ContactUs').set({});
                }

                try {
                    $('.contact_us_address').val(contactUsData.Address);
                    $('.contact_us_email').val(contactUsData.Email);
                    $('.contact_us_phone').val(contactUsData.Phone);

                } catch (error) {

                }
            })

            mapKey.get().then(async function (snapshots) {
                var key = snapshots.data();

                if (key == undefined) {
                    database.collection('settings').doc('googleMapKey').set({});
                }
                try {
                    $('#map_key').val(key.key);

                } catch (error) {

                }

            });

            DriverNearByRef.get().then(async function (snapshots) {

                var DriverNearData = snapshots.data();

                if (DriverNearData == undefined) {
                    database.collection('settings').doc('DriverNearBy').set({});
                }

                try {
                    $(".minimum_deposit_amount").val(DriverNearData.minimumDepositToRideAccept);
                    $(".minimum_withdrawal_amount").val(DriverNearData.minimumAmountToWithdrawal);

                    if (DriverNearData.mapType) {
                        $('#map_type').val(DriverNearData.mapType).trigger('change');
                    }
                    
                    if (DriverNearData.driverLocationUpdate) {
                        $('#driver_location_update').val(DriverNearData.driverLocationUpdate);
                    }

                    if(DriverNearData.singleOrderReceive ){
                        $('#single_order_receive').prop('checked',true);
                    }else{
                        $('#single_order_receive').prop('checked',false);
                    }
                    

                } catch (error) {

                }

            })

            referralAmountRef.get().then(async function (snapshots) {

                var referralAmountData = snapshots.data();

                if (referralAmountData == undefined) {
                    database.collection('settings').doc('referral_amount').set({});
                }

                try {
                    $(".referral_amount").val(referralAmountData.referralAmount);

                } catch (error) {

                }

                jQuery("#data-table_processing").hide();
            })

            refEmailSetting.get().then(async function (snapshots) {
                var emailSettingData = snapshots.data();

                if (emailSettingData == undefined) {
                    database.collection('settings').doc('emailSetting').set({});
                }

                try {

                    if (emailSettingData.fromName) {
                        $('.from_name').val(emailSettingData.fromName);

                    }
                    if (emailSettingData.host) {
                        $('.host').val(emailSettingData.host);

                    }

                    if (emailSettingData.port) {
                        $('.port').val(emailSettingData.port);

                    }

                    if (emailSettingData.userName) {
                        $('.user_name').val(emailSettingData.userName);

                    }
                    if (emailSettingData.password) {
                        $('.password').val(emailSettingData.password);

                    }

                } catch (error) {

                }

                jQuery("#data-table_processing").hide();

            });

            homepagethemeRef.get().then(async function (snapshots) {
                var themeData = snapshots.data();
                if(themeData.theme == "theme_1"){
                    $("#app_homepage_theme_1").prop('checked',true);
                }else if(themeData.theme == "theme_2"){
                    $("#app_homepage_theme_2").prop('checked',true);
                }
            });

        });

        $(".save_global_settings_btn").click(function () {

            var website_color = $("#website_color").val();
            var admin_color = $("#admin_color").val();
            var googleApiKey = $("#map_key").val();
            var store_color = $("#store_color").val();
            var contact_us_address = $('.contact_us_address').val();
            var contact_us_email = $('.contact_us_email').val();
            var contact_us_phone = $('.contact_us_phone').val();
            var app_version = $('.app_version').val();
            var web_version = $('#web_version').val();
            var auto_approve_restaurant = $("#auto_approve_restaurant").is(":checked");
            var restaurant_can_upload_story = $("#restaurant_can_upload_story").is(":checked");
            var story_upload_time = parseInt($('#story_upload_time').val());
            var minimumDepositToRideAccept = $(".minimum_deposit_amount").val();
            var minimumAmountToWithdrawal = $(".minimum_withdrawal_amount").val();
            var referralAmount = $(".referral_amount").val();
            var app_homepage_theme = $(".form-group input[name='app_homepage_theme']:checked").val();
            
            var fromName = $('.from_name').val();
            var host = $('.host').val();
            var port = $('.port').val();
            var userName = $('.user_name').val();
            var password = $('.password').val();

            if (admin_color != null) {
                setCookie('admin_panel_color', admin_color, 365);
            }

            var applicationName = $(".application_name").val();
            var meta_title = $(".meta_title").val();

            var map_type = $('#map_type').val();
            var driver_location_update = $('#driver_location_update').val();
            var single_order_receive = $("#single_order_receive").is(":checked");

            if (applicationName == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_app_name_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (minimumDepositToRideAccept == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_minimum_deposit_amount_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (minimumAmountToWithdrawal == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_minimum_withdrawal_amount_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (referralAmount == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_referral_amount_error')}}</p>");
                window.scrollTo(0, 0);
                window.scrollTo(0, 0);
            } else if (host == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.host_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (port == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.port_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (userName == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.username_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (password == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.password_error')}}</p>");
                window.scrollTo(0, 0);
            } else {

                jQuery("#data-table_processing").show();
                storeImageData().then(IMG => {
                database.collection('settings').doc("globalSettings").update({
                    'website_color': website_color,
                    'admin_panel_color': admin_color,
                    'store_panel_color': store_color,
                    'applicationName': applicationName,
                    'meta_title': meta_title,
                    'appLogo': IMG.photo,
                    'favicon': IMG.favicon,
                });

                database.collection('settings').doc('placeHolderImage').update({
                    'image': IMG.placeholderphoto
                });

                database.collection('settings').doc("ContactUs").update({
                    'Address': contact_us_address,
                    'Email': contact_us_email,
                    'Phone': contact_us_phone
                });

                database.collection('settings').doc("Version").update({
                    'app_version': app_version,
                    'web_version': web_version,
                });

                database.collection('settings').doc("restaurant").update({
                    'auto_approve_restaurant': auto_approve_restaurant,
                });

                database.collection('settings').doc("story").update({
                    'isEnabled': restaurant_can_upload_story,
                    'videoDuration': story_upload_time,
                });

                database.collection('settings').doc("googleMapKey").update({
                    'key': googleApiKey,
                });

                database.collection('settings').doc("DriverNearBy").update({
                    'minimumDepositToRideAccept': minimumDepositToRideAccept,
                    'minimumAmountToWithdrawal': minimumAmountToWithdrawal,
                    'mapType': map_type,
                    'driverLocationUpdate': driver_location_update,
                    'singleOrderReceive': single_order_receive
                });

                database.collection('settings').doc("referral_amount").update({
                    'referralAmount': referralAmount
                });

                database.collection('settings').doc('home_page_theme').update({
                    'theme': app_homepage_theme
                });

                database.collection('settings').doc("emailSetting").update({
                    'fromName': fromName,
                    'host': host,
                    'port': port,
                    'userName': userName,
                    'password': password,
                    'mailMethod': "smtp",
                    'mailEncryptionType': "ssl",
                }).then(function (result) {
                    window.location.href = '{{ url("settings/app/globals")}}';
                });
                }).catch(err => {
                    jQuery("#data-table_processing").hide();
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + err + "</p>");
                    window.scrollTo(0, 0);
                });

            }

        });

        $("#restaurant_can_upload_story").click(function () {
            if ($(this).is(':checked')) {
                $("#story_upload_time_div").show();
            } else {
                $("#story_upload_time_div").hide();
            }
        });

        $(".form-group input[name='app_homepage_theme']").click(function () {
            if ($(this).is(':checked')) {
                var modal = $('#themeModal');
                if ($(this).val() == "theme_1") {
                    modal.find('#themeImage').attr('src',theme_1_url);
                } else {
                    modal.find('#themeImage').attr('src',theme_2_url);
                }
                $('#themeModal').modal('show');
            }
        });

        $('#themeModal').on('hide.bs.modal', function (event) {
            var modal = $(this);
            modal.find('#themeImage').attr('src','');
        });
        
    var storageRef = firebase.storage().ref('images');

async function storeImageData() {
            var newPhoto = [];
            try {
                if(appLogoImagePath != "" && photo != appLogoImagePath){
                    var appLogoImagePathRef = await storage.refFromURL(appLogoImagePath);
                    /*await appLogoImagePathRef.delete().then(() => {
                        console.log("Old file deleted!")
                    }).catch((error) => {
                        console.log("ERR File delete ===", error);
                    });*/
                }
                if(photo != appLogoImagePath){
                    photo = photo.replace(/^data:image\/[a-z]+;base64,/, "")
                    var uploadTask = await storageRef.child(logoFileName).putString(photo, 'base64', {contentType:'image/jpg'});
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    newPhoto['photo'] = downloadURL;
                    photo = downloadURL;
                }else{
                    newPhoto['photo'] = photo;
                }
                if(appFavIconImagePath != "" && favicon != appFavIconImagePath){
                    var appFavIconImagePathRef = await storage.refFromURL(appFavIconImagePath);
                    /*await appFavIconImagePathRef.delete().then(() => {
                        console.log("Old file deleted!")
                    }).catch((error) => {
                        console.log("ERR File delete ===", error);
                    });*/
                }
                if(favicon != appFavIconImagePath){
                    favicon = favicon.replace(/^data:image\/[a-z]+;base64,/, "")
                    var uploadTask = await storageRef.child(favIconFileName).putString(favicon, 'base64', {contentType:'image/jpg'});
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    newPhoto['favicon'] = downloadURL;
                    favicon = downloadURL;
                }else{
                    newPhoto['favicon'] = favicon;
                }
                if(placeholderImagePath != "" && placeholderphoto != placeholderImagePath){
                    var placeholderImagePathRef = await storage.refFromURL(placeholderImagePath);
                    /*await placeholderImagePathRef.delete().then(() => {
                        console.log("Old file deleted!")
                    }).catch((error) => {
                        console.log("ERR File delete ===", error);
                    });*/
                }
                if(placeholderphoto != placeholderImagePath){
                    placeholderphoto = placeholderphoto.replace(/^data:image\/[a-z]+;base64,/, "")
                    var uploadTask = await storageRef.child(placeholderFileName).putString(placeholderphoto, 'base64', {contentType:'image/jpg'});
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    newPhoto['placeholderphoto'] = downloadURL;
                    placeholderphoto = downloadURL;
                }else{
                    newPhoto['placeholderphoto'] = placeholderphoto;
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
                    logoFileName=filename;
                    $(".logo_img_thumb").empty();
                    $(".logo_img_thumb").append('<span class="image-item"><img class="rounded" style="width:50px" src="' + filePayload + '" alt="image"></span>');

                    /*var uploadTask = storageRef.child(filename).put(theFile);
                    uploadTask.on('state_changed', function (snapshot) {
                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        jQuery("#uploding_image").text("Image is uploading...");

                    }, function (error) {

                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            jQuery("#uploding_image").text("Upload is completed");
                            photo = downloadURL;

                        });
                    });*/

                };
            })(f);
            reader.readAsDataURL(f);
        }


        function handleFileSelectplaceholder(evt) {

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
                    placeholderphoto = filePayload;
                    placeholderFileName=filename;
                    $(".placeholder_img_thumb").empty();
                    $(".placeholder_img_thumb").append('<span class="image-item"><img class="rounded" style="width:50px" src="' + filePayload + '" alt="image"></span>');

                    /*var uploadTask = storageRef.child(filename).put(theFile);
                    console.log(uploadTask);
                    uploadTask.on('state_changed', function (snapshot) {
                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        console.log('Upload is ' + progress + '% done');
                        jQuery("#uploading_placeholder").text("Image is uploading...");

                    }, function (error) {

                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            jQuery("#uploading_placeholder").text("Upload is completed");
                            placeholderphoto = downloadURL;

                        });
                    });*/

                };
            })(f);
            reader.readAsDataURL(f);
        }

        function handleFileSelectFavicon(evt) {

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
                    favicon = filePayload;
                    favIconFileName=filename;
                    $(".favicon_img_thumb").empty();
                    $(".favicon_img_thumb").append('<span class="image-item"><img class="rounded" style="width:50px" src="' + filePayload + '" alt="image"></span>');

                    /*var uploadTask = storageRef.child(filename).put(theFile);
                    console.log(uploadTask);
                    uploadTask.on('state_changed', function (snapshot) {
                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        console.log('Upload is ' + progress + '% done');
                        jQuery("#uploding_favicon").text("Image is uploading...");

                    }, function (error) {

                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            jQuery("#uploding_favicon").text("Upload is completed");
                            favicon = downloadURL;

                        });
                    });*/

                };
            })(f);
            reader.readAsDataURL(f);
        }

    </script>

@endsection
