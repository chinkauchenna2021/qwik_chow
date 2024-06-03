@extends('layouts.app')

@section('content')
<div class="page-wrapper">
  <div class="row page-titles">
    <div class="col-md-5 align-self-center">
      <h3 class="text-themecolor">{{trans('lang.driver_plural')}}</h3>
    </div>

    <div class="col-md-7 align-self-center">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
        <li class="breadcrumb-item"><a href="{!! route('drivers') !!}">{{trans('lang.driver_plural')}}</a></li>
        <li class="breadcrumb-item active">{{trans('lang.driver_edit')}}</li>
      </ol>
    </div>
    <div>

      <div class="card-body">

        <div id="data-table_processing" class="dataTables_processing panel panel-default" style="display: none;">
          {{trans('lang.processing')}}
        </div>
        <div class="error_top"></div>

        <div class="row restaurant_payout_create">
          <div class="restaurant_payout_create-inner">
            <fieldset>
              <legend>{{trans('lang.driver_details')}}</legend>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.first_name')}}</label>
                <div class="col-7">
                  <input type="text" class="form-control user_first_name">
                  <div class="form-text text-muted">{{trans('lang.first_name_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.last_name')}}</label>
                <div class="col-7">
                  <input type="text" class="form-control user_last_name">
                  <div class="form-text text-muted">{{trans('lang.last_name_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.email')}}</label>
                <div class="col-7">
                  <input type="email" class="form-control user_email">
                  <div class="form-text text-muted">{{trans('lang.user_email_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.password')}}</label>
                <div class="col-7">
                  <input type="password" class="form-control user_password">
                  <div class="form-text text-muted">{{trans('lang.user_password_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.user_phone')}}</label>
                <div class="col-7">
                  <input type="text" class="form-control user_phone" id="phone_chk">
                  <div id="error2" class="err"></div>
                  <div class="form-text text-muted">
                    {{trans('lang.user_phone_help')}}
                  </div>
                </div>
              </div>

              <div class="form-group row width-100">
                <div class="col-12">
                  <h6>{{ trans("lang.know_your_cordinates") }}<a target="_blank" href="https://www.latlong.net/">{{
                      trans("lang.latitude_and_longitude_finder") }}</a></h6>
                </div>
              </div>


              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.user_latitude')}}</label>
                <div class="col-7">
                  <input type="number" class="form-control user_latitude">
                  <div class="form-text text-muted">{{trans('lang.user_latitude_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.user_longitude')}}</label>
                <div class="col-7">
                  <input type="number" class="form-control user_longitude">
                  <div class="form-text text-muted">{{trans('lang.user_longitude_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-100">
                <label class="col-3 control-label">{{trans('lang.profile_image')}}</label>
                <div class="col-7">
                  <input type="file" onChange="handleFileSelect(event)" class="">
                  <div class="form-text text-muted">{{trans('lang.profile_image_help')}}</div>
                </div>
                <div class="placeholder_img_thumb user_image"></div>
                <div id="uploding_image"></div>
              </div>



              <div class="form-check width-100">
                <input type="checkbox" class="col-7 form-check-inline user_active" id="user_active">
                <label class="col-3 control-label" for="user_active">{{trans('lang.available')}}</label>
              </div>
            </fieldset>

            <fieldset>
              <legend>{{trans('driver')}} {{trans('lang.active_deactive')}}</legend>
              <div class="form-group row">

                <div class="form-group row width-50">
                  <div class="form-check width-100">
                    <input type="checkbox" id="is_active">
                    <label class="col-3 control-label" for="is_active">{{trans('lang.active')}}</label>
                  </div>
                </div>

              </div>
            </fieldset>

            <fieldset>
              <legend>{{trans('lang.car_details')}}</legend>
              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.car_number')}}</label>
                <div class="col-7">
                  <input type="text" class="form-control car_number">
                  <div class="form-text text-muted">{{trans('lang.car_number_help')}}</div>
                </div>
              </div>

              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.car_name')}}</label>
                <div class="col-7">
                  <input type="text" class="form-control car_name">
                  <div class="form-text text-muted">{{trans('lang.car_name_help')}}</div>
                </div>
              </div>
              <div class="form-group row width-50">
                <label class="col-3 control-label">{{trans('lang.car_image')}}</label>
                <div class="col-7">
                  <input type="file" onChange="handleFileSelectcar(event)" class="">
                  <div class="form-text text-muted">{{trans('lang.car_image_help')}}</div>
                </div>
                <div class="placeholder_img_thumb car_image">
                </div>
                <div id="uploding_image_car"></div>
              </div>

            </fieldset>
          </div>
        </div>
      </div>

      <div class="form-group col-12 text-center btm-btn">
        <button type="button" class="btn btn-primary save_driver_btn"><i class="fa fa-save"></i> {{
          trans('lang.save')}}</button>
        <a href="{!! route('drivers') !!}" class="btn btn-default"><i class="fa fa-undo"></i>{{
          trans('lang.cancel')}}</a>
      </div>

    </div>

  </div>


  @endsection

  @section('scripts')

  <script>
    var database = firebase.firestore();

    var photo = "";
    var fileName='';
    var photocar='';
    var carfileName='';
    var carPictureURL = "";
    var user_active_deactivate = false;
    var createdAt = firebase.firestore.FieldValue.serverTimestamp();
    var storageRef = firebase.storage().ref('images');
    var storage = firebase.storage();

    $(document).ready(function() {

      jQuery("#data-table_processing").show();

      jQuery("#data-table_processing").hide();

      /*function chkAlphabets(event, msg) {
        alert('hii');
      if (!(event.which >= 48 && event.which <= 57)) {
        document.getElementById(msg).innerHTML = "Accept only Number";
        return false; 
      } else {
        document.getElementById(msg).innerHTML = "";
        return true;
      }
      }*/

      $('#phone_chk').on('keypress',function(event){
      if (!(event.which >= 48 && event.which <= 57)) {
        document.getElementById('error2').innerHTML = "Accept only Number";
        return false; 
      } else {
        document.getElementById('error2').innerHTML = "";
        return true;
      }

      });
      
      $(".save_driver_btn").click( async function() {

        var userFirstName = $(".user_first_name").val();
        var userLastName = $(".user_last_name").val();
        var email = $(".user_email").val();
        var password = $(".user_password").val();
        var userPhone = $(".user_phone").val();
        var active = $(".user_active").is(":checked");
        user_active_deactivate = false;
        if ($("#is_active").is(':checked')) {
          user_active_deactivate = true;
        }
        var carName = $(".car_name").val();
        var carNumber = $(".car_number").val();
        var latitude = parseFloat($(".user_latitude").val());
        var longitude = parseFloat($(".user_longitude").val());
        var location = {
          'latitude': latitude,
          'longitude': longitude
        };
        var id = "<?php echo uniqid(); ?>";

        if (userFirstName == '') {
          $(".error_top").show();
          $(".error_top").html("");
          $(".error_top").append("<p>{{trans('lang.enter_owners_name_error')}}</p>");
          window.scrollTo(0, 0);

        } else if (email == '') {
          $(".error_top").show();
          $(".error_top").html("");
          $(".error_top").append("<p>{{trans('lang.enter_owners_email')}}</p>");
          window.scrollTo(0, 0);
        } else if (userPhone == '') {
          $(".error_top").show();
          $(".error_top").html("");
          $(".error_top").append("<p>{{trans('lang.enter_owners_phone')}}</p>");
          window.scrollTo(0, 0);
        } else if (carName == '') {
          $(".error_top").show();
          $(".error_top").html("");
          $(".error_top").append("<p>{{trans('lang.car_name_error')}}</p>");
          window.scrollTo(0, 0);
        } else if (carNumber == '') {
          $(".error_top").show();
          $(".error_top").html("");
          $(".error_top").append("<p>{{trans('lang.car_number_error')}}</p>");
          window.scrollTo(0, 0);
        } else {
         jQuery("#data-table_processing").show();

          firebase.auth().createUserWithEmailAndPassword(email, password)
            .then(function(firebaseUser) {
              id = firebaseUser.user.uid;
               storeImageData().then(IMG => {
                storeCarImageData().then(IMGCAR => {
              database.collection('users').doc(id).set({
                'id': id,
                'firstName': userFirstName,
                'lastName': userLastName,
                'email': email,
                'phoneNumber': userPhone,
                'isActive': active,
                'profilePictureURL': IMG,
                'carName': carName,
                'carNumber': carNumber,
                'location': location,
                'carPictureURL': IMGCAR,
                'role': 'driver',
                'active': user_active_deactivate,
                'createdAt': createdAt
              }).then(function(result) {
                jQuery("#data-table_processing").hide();
                window.location.href = '{{ route("drivers")}}';

              });
            }).catch(err => {
                        jQuery("#data-table_processing").hide();
                        $(".error_top").show();
                        $(".error_top").html("");
                        $(".error_top").append("<p>" + err + "</p>");
                        window.scrollTo(0, 0);
                    });
                }).catch(err => {
                    jQuery("#data-table_processing").hide();
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + err + "</p>");
                    window.scrollTo(0, 0);
                });

            }).catch(function(error) {
               jQuery("#data-table_processing").show();

              $(".error_top").show();
              $(".error_top").html("");
              $(".error_top").append("<p>" + error + "</p>");
              window.scrollTo(0, 0);
            });

        }

      })


    })

    async function storeImageData() {
        var newPhoto = '';
        try {
            if(photo!=""){
            photo = photo.replace(/^data:image\/[a-z]+;base64,/, "")
            var uploadTask = await storageRef.child(fileName).putString(photo, 'base64', {contentType: 'image/jpg'});
            var downloadURL = await uploadTask.ref.getDownloadURL();
            newPhoto = downloadURL;
            photo = downloadURL;
            }
        } catch (error) {
            console.log("ERR ===", error);
            return;
        }
        return newPhoto;
    }
    async function storeCarImageData() {
        var newCarPhoto = '';
        try {
            if(photocar!=""){
            photocar = photocar.replace(/^data:image\/[a-z]+;base64,/, "")
            var uploadTask = await storageRef.child(carfileName).putString(photocar, 'base64', {contentType: 'image/jpg'});
            var downloadURL = await uploadTask.ref.getDownloadURL();
            newCarPhoto = downloadURL;
            photocar = downloadURL;
            }
        } catch (error) {
            console.log("ERR ===", error);
            return;
           
        }
        return newCarPhoto;
    }


    function handleFileSelect(evt) {
      var f = evt.target.files[0];
      var reader = new FileReader();

      reader.onload = (function(theFile) {
        return function(e) {

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
        };
      })(f);
      reader.readAsDataURL(f);
    }

    function handleFileSelectcar(evt) {
        var f = evt.target.files[0];
        var reader = new FileReader();

        reader.onload = (function(theFile) {
            return function(e) {

                var filePayload = e.target.result;
                var val = f.name;
                var ext = val.split('.')[1];
                var docName = val.split('fakepath')[1];
                var filename = (f.name).replace(/C:\\fakepath\\/i, '')

                var timestamp = Number(new Date());
                var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                photocar = filePayload;
                carfileName = filename;

                $(".car_image").empty();
                $(".car_image").append('<img class="rounded" style="width:50px" src="' + photocar + '" alt="image">');

            };
        })(f);
        reader.readAsDataURL(f);
    }

  </script>
  @endsection