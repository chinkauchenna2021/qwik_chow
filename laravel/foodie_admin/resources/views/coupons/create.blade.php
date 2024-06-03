@extends('layouts.app')

@section('content')
<div class="page-wrapper">
    <div class="row page-titles">
        <div class="col-md-5 align-self-center">
            <h3 class="text-themecolor">{{trans('lang.coupon_plural')}}</h3>
        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <?php if ($id != '') { ?>
                    <li class="breadcrumb-item"><a href="{{route('restaurants.coupons',$id)}}">{{trans('lang.coupon_plural')}}</a>
                    </li>
                <?php } else { ?>
                    <li class="breadcrumb-item"><a href="{!! route('coupons') !!}">{{trans('lang.coupon_plural')}}</a>
                    </li>
                <?php } ?>
                <li class="breadcrumb-item active">{{trans('lang.coupon_create')}}</li>
            </ol>
        </div>
        <div>

            <div class="card-body">

                <div id="data-table_processing" class="dataTables_processing panel panel-default"
                     style="display: none;">{{trans('lang.processing')}}
                </div>
                <div class="error_top" style="display:none"></div>

                <div class="row restaurant_payout_create">

                    <div class="restaurant_payout_create-inner">

                        <fieldset>
                            <legend>{{trans('lang.coupon_create')}}</legend>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.coupon_code')}}</label>
                                <div class="col-7">
                                    <input type="text" type="text" class="form-control coupon_code">
                                    <div class="form-text text-muted">{{ trans("lang.coupon_code_help") }}</div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.coupon_discount_type')}}</label>
                                <div class="col-7">
                                    <select id="coupon_discount_type" class="form-control">
                                        <option value="Percentage">{{trans('lang.coupon_percent')}}</option>
                                        <option value="Fix Price">{{trans('lang.coupon_fixed')}}</option>
                                    </select>
                                    <div class="form-text text-muted">{{ trans("lang.coupon_discount_type_help") }}</div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.coupon_discount')}}</label>
                                <div class="col-7">
                                    <input type="number" type="text" class="form-control coupon_discount">
                                    <div class="form-text text-muted">{{ trans("lang.coupon_discount_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.coupon_expires_at')}}</label>
                                <div class="col-7">
                                    <div class='input-group date' id='datetimepicker1'>
                                        <input type='text' class="form-control date_picker input-group-addon"/>
                                        <span class=""></span>
                                    </div>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.coupon_expires_at_help") }}
                                    </div>
                                </div>
                            </div>
                            <?php if ($id == '') { ?>
                                <div class="form-group row width-50">
                                    <label class="col-3 control-label">{{trans('lang.coupon_restaurant_id')}}</label>
                                    <div class="col-7">
                                        <select id="vendor_restaurant_select" class="form-control">
                                            <option value="">{{trans('lang.select_restaurant')}}</option>
                                        </select>
                                        <div class="form-text text-muted">
                                            {{ trans("lang.coupon_restaurant_id_help") }}
                                        </div>
                                    </div>
                                </div>
                            <?php } ?>

                             <div class="form-group row width-50">
                                <div class="form-check">
                                 <input type="checkbox" class="coupon_public" id="coupon_public">
                                     <label class="col-3 control-label" for="coupon_public">{{trans('lang.coupon_public')}}</label>
                                </div>
                            </div>


                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.coupon_description')}}</label>
                                <div class="col-7">
                                    <textarea rows="12" class="form-control coupon_description"
                                              id="coupon_description"></textarea>
                                    <div class="form-text text-muted">{{ trans("lang.coupon_description_help") }}</div>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.category_image')}}</label>
                                <div class="col-7">
                                    <input type="file" onChange="handleFileSelect(event)">
                                    <div class="placeholder_img_thumb coupon_image"></div>
                                    <div id="uploding_image"></div>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <div class="form-check">
                                    <input type="checkbox" class="coupon_enabled" id="coupon_enabled">
                                    <label class="col-3 control-label" for="coupon_enabled">{{trans('lang.coupon_enabled')}}</label>

                                </div>
                            </div>

                            

                        </fieldset>
                    </div>

                </div>

            </div>

            <div class="form-group col-12 text-center btm-btn">
                <button type="button" class="btn btn-primary save_coupon_btn"><i class="fa fa-save"></i> {{
                    trans('lang.save')}}
                </button>
                <?php if ($id != '') { ?>
                    <a href="{{route('restaurants.coupons',$id)}}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
                <?php } else { ?>
                    <a href="{!! route('coupons') !!}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
                <?php } ?>
            </div>

        </div>

    </div>

</div>

@endsection

@section('scripts')

<script src="{{ asset('js/bootstrap-datepicker.min.js') }}"></script>
<link href="{{ asset('css/bootstrap-datepicker.min.css') }}" rel="stylesheet">

<script>

var database = firebase.firestore();

var photo_coupon = "";
var fileName="";
var restaurantOwnerId = "";
var restaurantOwnerOnline = false;

$(document).ready(function () {

    jQuery("#data-table_processing").show();

    database.collection('vendors').orderBy('title', 'asc').get().then(async function (snapshots) {

        snapshots.docs.forEach((listval) => {
            var data = listval.data();

            $('#vendor_restaurant_select').append($("<option></option>")
                .attr("value", data.id)
                .text(data.title));
        })

    });

    $(function () {
        $('#datetimepicker1').datepicker({
            dateFormat: 'mm/dd/yyyy'
        });
    });

    var id = "<?php echo uniqid();?>";
    var resturant = "<?php echo $id; ?>";
    var resturant_id = '';

    if (resturant == '') {
        $("#vendor_restaurant_select").change(function () {
            resturant_id = $(this).val();
        });
    } else {
        resturant_id = "<?php echo $id; ?>";
    }

    $(".save_coupon_btn").click(function () {


        var code = $(".coupon_code").val();
        var discount = $(".coupon_discount").val();
        var description = $(".coupon_description").val();
        var newdate = new Date($(".date_picker").val());
        console.log(newdate);
        var expiresAt = new Date(newdate.setHours(23, 59, 59, 999));
        console.log(expiresAt);
        var isEnabled = $(".coupon_enabled").is(":checked");
        var isPublic = $(".coupon_public").is(":checked");
        var discountType = $("#coupon_discount_type").val();

        if (code == '') {
            $(".error_top").show();
            $(".error_top").html("");
            $(".error_top").append("<p>{{trans('lang.enter_coupon_code_error')}}</p>");
            window.scrollTo(0, 0);
        } else if (discount == '') {
            $(".error_top").show();
            $(".error_top").html("");
            $(".error_top").append("<p>{{trans('lang.enter_coupon_discount_error')}}</p>");
            window.scrollTo(0, 0);
        } else if (discountType == '') {
            $(".error_top").show();
            $(".error_top").html("");
            $(".error_top").append("<p>{{trans('lang.select_coupon_discountType_error')}}</p>");
            window.scrollTo(0, 0);
        } else if (newdate == 'Invalid Date') {
            $(".error_top").show();
            $(".error_top").html("");
            $(".error_top").append("<p>{{trans('lang.select_coupon_expdate_error')}}</p>");
            window.scrollTo(0, 0);
            
        } else {

			jQuery("#data-table_processing").show();
            storeImageData().then(IMG => {
            database.collection('coupons').doc(id).set({
                'code': code,
                'description': description,
                'discount': discount,
                'expiresAt': expiresAt,
                'isEnabled': isEnabled,
                'id': id,
                'discountType': discountType,
                'image': IMG,
                'resturant_id': resturant_id,
                'isPublic':isPublic
            }).then(function (result) {
                if (resturant) {
				    jQuery("#data-table_processing").hide();
                    window.location.href = "{{route('restaurants.coupons',$id)}}";
                } else {
			    	jQuery("#data-table_processing").hide();
                    window.location.href = '{{ route("coupons")}}';
                }
                //window.location.href = '{{ route("coupons")}}';
            });
            }).catch(function (error) {
				jQuery("#data-table_processing").hide();
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>" + error + "</p>");
            }); 
        }
    })

    jQuery("#data-table_processing").hide();

});

var storageRef = firebase.storage().ref('images');

async function storeImageData() {
        var newPhoto = '';
        try {
            photo_coupon = photo_coupon.replace(/^data:image\/[a-z]+;base64,/, "")
            var uploadTask = await storageRef.child(fileName).putString(photo_coupon, 'base64', {contentType: 'image/jpg'});
            var downloadURL = await uploadTask.ref.getDownloadURL();
            newPhoto = downloadURL;
            photo_coupon = downloadURL;
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
            var hash = CryptoJS.SHA256(Math.random() + CryptoJS.SHA256(filePayload));
            var val = f.name;
            var ext = val.split('.')[1];
            var docName = val.split('fakepath')[1];
            var filename = (f.name).replace(/C:\\fakepath\\/i, '')
            var timestamp = Number(new Date());
            var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
            photo_coupon = filePayload;
            fileName=filename;
            $(".coupon_image").empty();
            $(".coupon_image").append('<img class="rounded" style="width:50px" src="' + photo_coupon + '" alt="image">');

           /* var uploadTask = storageRef.child(filename).put(theFile);
            uploadTask.on('state_changed', function (snapshot) {
                var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                jQuery("#uploding_image").text("Image is uploading...");

            }, function (error) {
            }, function () {
                uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                    jQuery("#uploding_image").text("Upload is completed");
                    photo_coupon = downloadURL;
                    $(".coupon_image").empty();
                    $(".coupon_image").append('<img class="rounded" style="width:50px" src="' + photo_coupon + '" alt="image">');


                });
            });*/

        };
    })(f);
    reader.readAsDataURL(f);
}

</script>
@endsection