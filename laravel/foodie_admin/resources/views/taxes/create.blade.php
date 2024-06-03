@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">
            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{trans('lang.tax_plural')}}</h3>
            </div>

            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{!! route('tax') !!}">{{trans('lang.tax_plural')}}</a></li>
                    <li class="breadcrumb-item active">{{trans('lang.tax_create')}}</li>
                </ol>
            </div>
        </div>
        <div class="container-fluid">
            <div class="card pb-4">
                <div class="card-body">

                    <div class="error_top"></div>

                    <div class="row restaurant_payout_create">
                        <div class="restaurant_payout_create-inner">
                            <fieldset>
                                <legend>{{trans('lang.tax_details')}}</legend>

                                <div class="form-group row width-50">
                                    <label class="col-3 control-label">{{trans('lang.tax_title')}}<span
                                                class="required-field"></span></label>
                                    <div class="col-7">
                                        <input type="text" class="form-control tax_title">
                                        <div class="form-text text-muted">
                                            {{ trans("lang.tax_title_help") }}
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row width-50">
                                    <label class="col-3 control-label">{{trans('lang.country')}}<span
                                                class="required-field"></span></label>
                                    <div class="col-7">
                                        <select name="country" id="country" class="form-control tax_country">
                                            @foreach($countries_data as $country)
                                                <option
                                                        value="{{$country->countryName}}">{{$country->countryName}}
                                                </option>
                                            @endforeach
                                        </select>

                                        <div class="form-text text-muted">
                                            {{ trans("lang.tax_country_help") }}
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row width-50">
                                    <label class="col-3 control-label">{{trans('lang.tax_type')}}<span
                                                class="required-field"></span></label>
                                    <div class="col-7">
                                        <select class="form-control tax_type">
                                            <option value="fix">
                                                {{trans('lang.fix')}}
                                            </option>
                                            <option value="percentage">
                                                {{trans('lang.percentage')}}
                                            </option>
                                        </select>
                                        <div class="form-text text-muted">
                                            {{ trans("lang.tax_type_help") }}
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row width-50">
                                    <label class="col-3 control-label">{{trans('lang.tax_amount')}}<span
                                                class="required-field"></span></label>
                                    <div class="col-7">
                                        <input type="number" class="form-control tax_amount" min="0">
                                        <div class="form-text text-muted w-50">
                                            {{ trans("lang.tax_amount_help") }}
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row width-100">
                                    <div class="form-check">
                                        <input type="checkbox" class="tax_active" id="tax_active">
                                        <label class="col-3 control-label"
                                               for="tax_active">{{trans('lang.enable')}}</label>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>

                    <div class="form-group col-12 text-center btm-btn">
                        <button type="button" class="btn btn-primary  create_user_btn"><i class="fa fa-save"></i> {{
                        trans('lang.save')}}
                        </button>
                        <a href="{!! route('tax') !!}" class="btn btn-default"><i class="fa fa-undo"></i>{{
                        trans('lang.cancel')}}</a>
                    </div>

                </div>
            </div>
        </div>

    </div>

@endsection

@section('scripts')

    <script>

        var database = firebase.firestore();


        $(document).ready(function () {
            $('.tax_menu').addClass('active');
        });

        $(".create_user_btn").click(function () {

            var title = $(".tax_title").val();
            var country = $(".tax_country").val();
            var type = $(".tax_type :selected").val();
            var tax = $(".tax_amount").val();
            var enable = false;

            if ($(".tax_active").is(':checked')) {
                enable = true;
            }

            var id = database.collection("tmp").doc().id;

            if (title == '') {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.tax_title_error')}}</p>");
                window.scrollTo(0, 0);
            } else if (tax == '' || tax <= 0) {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.tax_amount_error')}}</p>");
                window.scrollTo(0, 0);
            } else {
                jQuery("#overlay").show();
                database.collection('tax').doc(id).set({

                    'title': title,
                    'country': country,
                    'tax': tax,
                    'type': type,
                    'id': id,
                    'enable': enable,

                }).then(function (result) {
                    jQuery("#overlay").hide();
                    window.location.href = '{{ route("tax")}}';
                }).catch(function (error) {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + error + "</p>");
                });
            }
        })


    </script>
@endsection
