<!doctype html>

<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>

    <meta charset="utf-8">

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->

    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title id="app_name"><?php echo @$_COOKIE['meta_title']; ?></title>

    <link rel="icon" id="favicon" type="image/x-icon" href="<?php echo str_replace('images/','images%2F',@$_COOKIE['favicon']); ?>">

    <!-- Fonts -->

    <link rel="dns-prefetch" href="//fonts.gstatic.com">

    <link href="https://fonts.googleapis.com/css?family=Nunito" rel="stylesheet">

    <!-- Styles -->

    <link href="{{ asset('assets/plugins/bootstrap/css/bootstrap.min.css') }}" rel="stylesheet">

    <link href="{{ asset('css/style.css') }}" rel="stylesheet">

    @yield('style')


</head>

<body>

<style type="text/css">
    .form-group.default-admin {
        padding: 10px;
        font-size: 14px;
        color: #000;
        font-weight: 600;
        border-radius: 10px;
        box-shadow: 0 0px 6px 0px rgba(0, 0, 0, 0.5);
        margin: 20px 10px 10px 10px;
    }

    .form-group.default-admin .crediantials-field {
        position: relative;
        padding-right: 15px;
        text-align: left;
        padding-top: 5px;
        padding-bottom: 5px;
    }

    .form-group.default-admin .crediantials-field > a {
        position: absolute;
        right: 0;
        top: 0;
        bottom: 0;
        margin: auto;
        height: 20px;
    }

    .login-register {
        background-color: #FF683A;
    }

    <?php if(isset($_COOKIE['admin_panel_color'])){ ?>
    a, a:hover, a:focus {
        color: <?php echo $_COOKIE['admin_panel_color']; ?>;
    }

    .btn-primary, .btn-primary.disabled, .btn-primary:hover, .btn-primary.disabled:hover {
        background: <?php echo $_COOKIE['admin_panel_color']; ?>;
        border: 1px solid<?php echo $_COOKIE['admin_panel_color']; ?>;
    }

    [type="checkbox"]:checked + label::before {
        border-right: 2px solid<?php echo $_COOKIE['admin_panel_color']; ?>;
        border-bottom: 2px solid<?php echo $_COOKIE['admin_panel_color']; ?>;
    }

    .form-material .form-control, .form-material .form-control.focus, .form-material .form-control:focus {
        background-image: linear-gradient(<?php echo $_COOKIE['admin_panel_color']; ?>, <?php echo $_COOKIE['admin_panel_color']; ?>), linear-gradient(rgba(120, 130, 140, 0.13), rgba(120, 130, 140, 0.13));
    }

    .btn-primary.active, .btn-primary:active, .btn-primary:focus, .btn-primary.disabled.active, .btn-primary.disabled:active, .btn-primary.disabled:focus, .btn-primary.active.focus, .btn-primary.active:focus, .btn-primary.active:hover, .btn-primary.focus:active, .btn-primary:active:focus, .btn-primary:active:hover, .open > .dropdown-toggle.btn-primary.focus, .open > .dropdown-toggle.btn-primary:focus, .open > .dropdown-toggle.btn-primary:hover, .btn-primary.focus, .btn-primary:focus, .btn-primary:not(:disabled):not(.disabled).active:focus, .btn-primary:not(:disabled):not(.disabled):active:focus, .show > .btn-primary.dropdown-toggle:focus {
        background: <?php echo $_COOKIE['admin_panel_color']; ?>;
        border-color: <?php echo $_COOKIE['admin_panel_color']; ?>;
        box-shadow: 0 0 0 0.2rem<?php echo $_COOKIE['admin_panel_color']; ?>;
    }

    .login-register {
        background-color: <?php echo $_COOKIE['admin_panel_color']; ?>;
    }

    <?php } ?>

</style>


<section id="wrapper">


    <div class="login-register">


        <div class="login-logo text-center py-3">

            <a href="#" style="display: inline-block;background: #fff;padding: 10px;border-radius: 5px;"><img
                        src="{{ asset('images/logo_web.png') }}"> </a>

        </div>

        <div class="login-box card" style="margin-bottom:0%;">
    
            <div class="card-body">

                @if(count($errors) > 0)
                    @foreach( $errors->all() as $message )
                        <div class="alert alert-danger display-hide">
                            <button class="close" data-close="alert"></button>
                            <span>{{ $message }}</span>
                        </div>
                    @endforeach
                @endif

                <form class="form-horizontal form-material" method="POST" action="{{ route('login') }}">

                    @csrf

                    <div class="box-title m-b-20">{{ __('Login') }}</div>


                    <div class="form-group ">


                        <div class="col-xs-12">


                            <input class="form-control" placeholder="{{ __('Email Address') }}" id="email" type="email"
                                   class="form-control @error('email') is-invalid @enderror" name="email"
                                   value="{{ old('email') }}" required autocomplete="email" autofocus></div>


                        @error('email')

                        <span class="invalid-feedback" role="alert">

                                            <strong>{{ $message }}</strong>

                                        </span>

                        @enderror


                    </div>


                    <div class="form-group">


                        <div class="col-xs-12">


                            <input id="password" placeholder="{{ __('Password') }}" type="password"
                                   class="form-control @error('password') is-invalid @enderror" name="password" required
                                   autocomplete="current-password"></div>


                        @error('password')

                        <span class="invalid-feedback" role="alert">

                                                <strong>{{ $message }}</strong>

                                            </span>

                        @enderror


                    </div>


                    <div class="form-group text-center m-t-20">


                        <div class="col-xs-12">


                            <input class="form-check-input" type="checkbox" name="remember" id="remember" {{ old('remember')
                            ? 'checked' : '' }}>


                            <label class="form-check-label" for="remember">

                                {{ __('Remember Me') }}

                            </label>


                        </div>


                    </div>


                    <div class="form-group text-center m-t-20 mb-0">


                        <div class="col-xs-12">


                            <button type="submit"
                                    class="btn btn-dark btn-lg btn-block text-uppercase waves-effect waves-light btn btn-primary">

                                {{ __('Login') }}

                            </button>


                        </div>


                    </div>
                    

                </form>

            </div>

        </div>

    </div>

</section>

<script src="{{asset('assets/plugins/jquery/jquery.min.js')}}"></script>
<script src="https://www.gstatic.com/firebasejs/8.0.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.0.0/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.0.0/firebase-storage.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.0.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.0.0/firebase-database.js"></script>
<script src="https://unpkg.com/geofirestore/dist/geofirestore.js"></script>
<script src="https://cdn.firebase.com/libs/geofire/5.0.1/geofire.min.js"></script>
<script src="{{ asset('js/crypto-js.js') }}"></script>
<script src="{{ asset('js/jquery.cookie.js') }}"></script>
<script src="{{ asset('js/jquery.validate.js') }}"></script>

<script type="text/javascript">

    function copyToClipboard(text) {
        const elem = document.createElement('textarea');
        elem.value = text;
        document.body.appendChild(elem);
        elem.select();
        document.execCommand('copy');
        document.body.removeChild(elem);
    }

    var database = firebase.firestore();
    var ref = database.collection('settings').doc("globalSettings");
    $(document).ready(function () {
        ref.get().then(async function (snapshots) {
            var globalSettings = snapshots.data();
            setCookie('application_name', globalSettings.applicationName, 365);
            setCookie('meta_title', globalSettings.meta_title, 365);
            setCookie('favicon', globalSettings.favicon, 365);
            admin_panel_color = globalSettings.admin_panel_color;
            setCookie('admin_panel_color', admin_panel_color, 365);
            $('.login-register').css({'background-color': admin_panel_color});
            document.title = globalSettings.meta_title;
            var favicon = '<?php echo @$_COOKIE['favicon'] ?>';
        })
    });

    function setCookie(cname, cvalue, exdays) {
        const d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        let expires = "expires=" + d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }
</script>

</body>

</html>
