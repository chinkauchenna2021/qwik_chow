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
				<li class="breadcrumb-item active">{{trans('lang.user_create')}}</li>
			</ol>
		</div>
		<div>

			<div class="card-body">

				<div id="data-table_processing" class="dataTables_processing panel panel-default"
					style="display: none;">{{trans('lang.processing')}}</div>
				<div class="error_top"></div>

				<div class="row restaurant_payout_create">
					<div class="restaurant_payout_create-inner">
						<fieldset>
							<legend>{{trans('lang.user_details')}}</legend>

							<div class="form-group row width-50">
								<label class="col-3 control-label">{{trans('lang.first_name')}}</label>
								<div class="col-7">
									<input type="text" class="form-control user_first_name" id="firstname"  onkeypress="return chkAlphabets(event,'error')">
									<div id="error" class="err"></div>
									<div class="form-text text-muted">
										{{ trans("lang.user_first_name_help") }}
									</div>
								</div>
							</div>

							<div class="form-group row width-50">
								<label class="col-3 control-label">{{trans('lang.last_name')}}</label>
								<div class="col-7">
									<input type="text" class="form-control user_last_name" onkeypress="return chkAlphabets(event,'error1')">
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
								<label class="col-3 control-label">{{trans('lang.password')}}</label>
								<div class="col-7">
									<input type="password" class="form-control user_password">
									<div class="form-text text-muted">
										{{ trans("lang.user_password_help") }}
									</div>
								</div>
							</div>


							<div class="form-group row width-50">
								<label class="col-3 control-label">{{trans('lang.user_phone')}}</label>
								<div class="col-7">
									<input type="text" class="form-control user_phone"  onkeypress="return chkAlphabets2(event,'error2')">
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
							<div class="form-group row">

								<div class="form-group row width-50">
									<div class="form-check width-100">
										<input type="checkbox" class="user_active" id="user_active">
										<label class="col-3 control-label"
											for="user_active">{{trans('lang.active')}}</label>
									</div>
								</div>

							</div>
						</fieldset>

					</div>
				</div>
			</div>

			<div class="form-group col-12 text-center btm-btn">
				<button type="button" class="btn btn-primary  create_user_btn"><i class="fa fa-save"></i> {{
					trans('lang.save')}}</button>
				<a href="{!! route('users') !!}" class="btn btn-default"><i class="fa fa-undo"></i>{{
					trans('lang.cancel')}}</a>
			</div>

		</div>

	</div>

</div>


@endsection

@section('scripts')

<script>

	var database = firebase.firestore();
	var createdAt = firebase.firestore.FieldValue.serverTimestamp();
	var photo = "";
	var fileName='';
	$(".create_user_btn").click(function () {

		var userFirstName = $(".user_first_name").val();
		var userLastName = $(".user_last_name").val();
		var email = $(".user_email").val();
		var password = $(".user_password").val();
		var userPhone = $(".user_phone").val();
		var active = $(".user_active").is(":checked");
		var role = $("#user_role option:selected").val();
		var user_name = userFirstName + " " + userLastName;
		var vendorRestaurantSelect = $("#vendor_restaurant_select option:selected").val();
		var id = "<?php echo uniqid(); ?>";
		var name = userFirstName + " " + userLastName;

		if (userFirstName == '') {
			$(".error_top").show();
			$(".error_top").html("");
			$(".error_top").append("<p>{{trans('lang.user_firstname_error')}}</p>");
			window.scrollTo(0, 0);

		} else if (email == '') {
			$(".error_top").show();
			$(".error_top").html("");
			$(".error_top").append("<p>{{trans('lang.user_email_error')}}</p>");
			window.scrollTo(0, 0);
		} else if (password == '') {
			$(".error_top").show();
			$(".error_top").html("");
			$(".error_top").append("<p>{{trans('lang.user_password_error')}}</p>");
			window.scrollTo(0, 0);
		} else if (userPhone == '') {
			$(".error_top").show();
			$(".error_top").html("");
			$(".error_top").append("<p>{{trans('lang.user_phone_error')}}</p>");
			window.scrollTo(0, 0);
		} 

		 else {
            jQuery("#data-table_processing").show();

			firebase.auth().createUserWithEmailAndPassword(email, password)
				.then(function (firebaseUser) {
					var user_id = firebaseUser.user.uid;

            storeImageData().then(IMG => {
					database.collection('users').doc(user_id).set({ 
						'firstName': userFirstName,
						'lastName': userLastName, 
						'email': email,
						'phoneNumber': userPhone, 
						'profilePictureURL': IMG,
						'role': 'customer', 
						'shippingAddress': '',
						'active': active, 
						'id': user_id, 
						'createdAt': createdAt
					 }).then(function (result) {
						jQuery("#data-table_processing").hide();
						window.location.href = '{{ route("users")}}';
					});           
				}).catch(function (error) {
				jQuery("#data-table_processing").hide();
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>" + error + "</p>");
            })
		}).catch(function (error) {
					jQuery("#data-table_processing").hide();
					$(".error_top").show();
					$(".error_top").html("");
					$(".error_top").append("<p>" + error + "</p>");
				});
		}
	})


	var storageRef = firebase.storage().ref('images');
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

				//var uploadTask = storageRef.child(filename).put(theFile);
				//console.log(uploadTask);
				/*uploadTask.on('state_changed', function (snapshot) {

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

	
function chkAlphabets(event,msg)
	{
		if(!(event.which>=97 && event.which<=122) && !(event.which>=65 && event.which<=90) )
		{
		document.getElementById(msg).innerHTML="Accept only Alphabets";
		return false;
		}
		else
		{
		document.getElementById(msg).innerHTML="";
		return true;
		}
	}

	function chkAlphabets2(event,msg)
	{
		if(!(event.which>=48  && event.which<=57)
		)
		{
		document.getElementById(msg).innerHTML="Accept only Number";
		return false;
		}
		else
		{
		document.getElementById(msg).innerHTML="";
		return true;
		}
	}
	function chkAlphabets3(event,msg)
	{
		if(!((event.which>=48  && event.which<=57) || (event.which>=97 && event.which<=122)))
		{
		document.getElementById(msg).innerHTML="Special characters not accepted ";
		return false;
		}
		else
		{
		document.getElementById(msg).innerHTML="";
		return true;
		}
	}
</script>
@endsection