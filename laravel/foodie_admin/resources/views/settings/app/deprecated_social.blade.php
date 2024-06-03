@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">

            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{trans('lang.app_setting_social')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item active">{{trans('lang.app_setting_social')}}</li>
                </ol>
            </div>
        </div>

        <div class="card-body">
            <div id="data-table_processing" class="dataTables_processing panel panel-default" style="display: none;">
                Processing...
            </div>
            <div class="row restaurant_payout_create">
                <div class="restaurant_payout_create-inner">
                    <fieldset>
                        <legend><i class="mr-3 fa fa-facebook"></i>{{trans('lang.app_setting_facebook')}}</legend>

                        <div class="form-check width-100">
                            <input type="checkbox" class="enable_facebook" id="enable_facebook">
                            <label class="col-5 control-label"
                                   for="enable_facebook">{{trans('lang.app_setting_enable_facebook')}}</label>
                            <div class="form-text text-muted">
                                {!! trans('lang.app_setting_enable_facebook_help') !!}
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.app_setting_facebook_app_id')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control fb_app_id">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_facebook_app_id_help') !!}
                                </div>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-3 control-label">{{trans('lang.app_setting_facebook_app_secret')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control fb_app_secret">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_facebook_app_secret_help') !!}
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 fa fa-twitter"></i>{!! trans('lang.app_setting_twitter') !!}</legend>

                        <div class="form-check width-100">
                            <input type="checkbox" class="enable_twitter" id="enable_twitter">
                            <label class="col-5 control-label"
                                   for="enable_twitter">{{trans('lang.app_setting_enable_twitter')}}</label>
                            <div class="form-text text-muted">
                                {!! trans('lang.app_setting_enable_twitter_help') !!}
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.app_setting_twitter_app_id')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control twitter_app_id">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_twitter_app_id_help') !!}
                                </div>
                            </div>
                        </div>
                        <div class="form-group row width-100">
                            <label class="col-5 control-label">{{trans('lang.app_setting_twitter_app_secret')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control twitter_app_secret">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_twitter_app_secret_help') !!}
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend><i class="mr-3 fa fa-google"></i>{!! trans('lang.app_setting_google') !!}</legend>

                        <div class="form-check width-100">
                            <input type="checkbox" class=" enable_google" id="enable_google">
                            <label class="col-5 control-label"
                                   for="enable_google">{{trans('lang.app_setting_enable_google')}}</label>
                            <div class="form-text text-muted">
                                {!! trans('lang.app_setting_enable_google_help') !!}
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-5 control-label">{{trans('lang.app_setting_google_app_id')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control google_app_id">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_google_app_id_help') !!}
                                </div>
                            </div>
                        </div>

                        <div class="form-group row width-100">
                            <label class="col-5 control-label">{{trans('lang.app_setting_google_app_secret')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control google_app_secret">
                                <div class="form-text text-muted">
                                    {!! trans('lang.app_setting_google_app_secret_help') !!}
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>
        </div>
        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary social_auth_btn"><i
                        class="fa fa-save"></i> {{trans('lang.save')}}</button>
            <a href="{{url('/dashboard')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}
            </a>
        </div>

    </div>
    </div>

@endsection

@section('scripts')

    <script>


        var database = firebase.firestore();
        var ref = database.collection('settings').doc("socialAuth");


        $(document).ready(function () {
            jQuery("#data-table_processing").show();
            ref.get().then(async function (snapshots) {
                var socialAuth = snapshots.data();

                if (socialAuth == undefined) {
                    database.collection('settings').doc('socialAuth').set({});
                }

                try {
                    if (socialAuth.is_fb_enabled) {
                        $(".enable_facebook").prop("checked", true);
                    }
                    $(".fb_app_id").val(socialAuth.facebook_app_id);
                    $(".fb_app_secret").val(socialAuth.facebook_app_secret);
                    if (socialAuth.is_twitter_enabled) {
                        $(".enable_twitter").prop("checked", true);
                    }
                    $(".twitter_app_id").val(socialAuth.twitter_app_id);
                    $(".twitter_app_secret").val(socialAuth.twitter_app_secret);
                    if (socialAuth.is_google_enabled) {
                        $(".enable_google").prop("checked", true);
                    }

                    $(".google_app_id").val(socialAuth.google_app_id);
                    $(".google_app_secret").val(socialAuth.google_app_secret);

                } catch (error) {

                }
                jQuery("#data-table_processing").hide();

            })

            $(".social_auth_btn").click(function () {

                var fbEnabled = $(".enable_facebook").is(":checked");
                var fbAppId = $(".fb_app_id").val();
                var fbAppSecret = $(".fb_app_secret").val();
                var twitterEnabled = $(".enable_twitter").is(":checked");
                var twitterAppId = $(".twitter_app_id").val();
                var twitterAppSecret = $(".twitter_app_secret").val();
                var googleEnabled = $(".enable_google").is(":checked");
                var googleAppId = $(".google_app_id").val();
                var googleAppSecret = $(".google_app_secret").val();

                database.collection('settings').doc("socialAuth").update({
                    'is_fb_enabled': fbEnabled,
                    'facebook_app_id': fbAppId,
                    'facebook_app_secret': fbAppSecret,
                    'is_twitter_enabled': twitterEnabled,
                    'twitter_app_id': twitterAppId,
                    'twitter_app_secret': twitterAppSecret,
                    'is_google_enabled': googleEnabled,
                    'google_app_id': googleAppId,
                    'google_app_secret': googleAppSecret
                }).then(function (result) {
                    window.location.href = '{{ url()->current() }}';
                });


            })
        })

    </script>

@endsection