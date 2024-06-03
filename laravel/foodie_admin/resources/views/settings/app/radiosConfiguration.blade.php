@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">

            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{ trans('lang.radios_configuration')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item active">{{ trans('lang.radios_configuration')}}</li>
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
                        <legend>{{trans('lang.radios_configuration')}}</legend>
                        <div class="form-group row width-50">
                            <label class="col-4 control-label">{{ trans('lang.restaurantnearby_radios')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control restaurant_near_by" required>
                                    <span>{{ trans('lang.miles')}}</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-4 control-label">{{ trans('lang.driver_nearby_radios')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control driver_nearby_radios" required>
                                    <span>{{ trans('lang.miles')}}</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group row width-50">
                            <label class="col-4 control-label">{{ trans('lang.driverOrderAcceptRejectDuration')}}</label>
                            <div class="col-7">
                                <div class="control-inner">
                                    <input type="number" class="form-control driverOrderAcceptRejectDuration" required>
                                    <span>{{ trans('lang.second')}}</span>
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>
        </div>
        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary restaurant_near_by_save_btn"><i
                        class="fa fa-save"></i> {{trans('lang.save')}}</button>
            <a href="{{url('/dashboard')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}
            </a>
        </div>
    </div>

@endsection

@section('scripts')

    <script>

        var database = firebase.firestore();
        var ref = database.collection('settings').doc("RestaurantNearBy");
        var refDriver = database.collection('settings').doc("DriverNearBy");

        $(document).ready(function () {

            jQuery("#data-table_processing").show();

            ref.get().then(async function (snapshots) {

                var radios = snapshots.data();

                if (radios == undefined) {
                    database.collection('settings').doc('RestaurantNearBy').set({});
                }

                try {
                    $(".restaurant_near_by").val(radios.radios);

                } catch (error) {

                }
            });

            refDriver.get().then(async function (snapshots) {
                var radios = snapshots.data();

                if (radios == undefined) {
                    database.collection('settings').doc('DriverNearBy').set({});
                }

                try {
                    $(".driver_nearby_radios").val(radios.driverRadios);
                    $(".driverOrderAcceptRejectDuration").val(radios.driverOrderAcceptRejectDuration);

                } catch (error) {

                }

            });
            jQuery("#data-table_processing").hide();

        });


        $(".restaurant_near_by_save_btn").click(function () {

            var restaurantNearBy = $(".restaurant_near_by").val();
            var driverOrderAcceptRejectDuration = $(".driverOrderAcceptRejectDuration").val();
            var driverNearBy = $(".driver_nearby_radios").val();

            if (restaurantNearBy == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_restaurant_nearby_error')}}</p>");
            } else if (driverNearBy == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_driver_nearby_radios_error')}}</p>");
            } else if (driverOrderAcceptRejectDuration == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.driverOrderAcceptRejectDuration_error')}}</p>");
            } else {

                jQuery("#data-table_processing").show();
                database.collection('settings').doc("RestaurantNearBy").update({
                    'radios': restaurantNearBy
                }).then(function (result) {
                    database.collection('settings').doc("DriverNearBy").update({
                        'driverRadios': driverNearBy,
                        'driverOrderAcceptRejectDuration': Number(driverOrderAcceptRejectDuration)
                    }).then(function (result) {
                        window.location.href = '{{ url()->current() }}';
                    });
                })
            }

        })

    </script>

@endsection