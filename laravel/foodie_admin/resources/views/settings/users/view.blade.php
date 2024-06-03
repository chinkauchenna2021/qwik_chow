@extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">

            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor restaurantTitle">{{trans('lang.user_plural')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{!! route('users') !!}">{{trans('lang.user_plural')}}</a>
                    </li>
                    <li class="breadcrumb-item active">{{trans('lang.user_details')}}</li>
                </ol>
            </div>

        </div>

        <div class="container-fluid">
            <div class="row">
                <div class="col-12">

                    <div class="resttab-sec">
                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">Processing...
                        </div>
                        <div class="menu-tab">

                            <ul>
                                <li class="active">
                                    <a href="{{route('users.view',$id)}}">{{trans('lang.tab_basic')}}</a>
                                </li>
                                <li>
                                    <a href="{{route('orders','userId='.$id)}}">{{trans('lang.tab_orders')}}</a>
                                </li>
                                <li>
                                    <a
                                            href="{{route('users.walletstransaction',$id)}}">{{trans('lang.wallet_transaction')}}</a>
                                </li>

                            </ul>

                        </div>

                        <div class="row restaurant_payout_create user_details">
                            <div class="restaurant_payout_create-inner">
                                <a href="javascript:void(0)" data-toggle="modal" data-target="#addWalletModal"
                                   class="add-wallate btn btn-success"><i
                                            class="fa fa-plus"></i>{{trans('lang.add_wallet_amount')}}</a>

                                <fieldset>

                                    <legend>{{trans('lang.user_details')}}</legend>

                                    <div class="form-group row width-50">
                                        <label class="col-3 control-label">{{trans('lang.first_name')}}</label>
                                        <div class="col-7">
                                            <span class="user_name" id="user_name"></span>
                                        </div>
                                    </div>

                                    <div class="form-group row width-50">
                                        <label class="col-3 control-label">{{trans('lang.email')}}</label>
                                        <div class="col-7">
                                            <span class="email"></span>
                                        </div>
                                    </div>

                                    <div class="form-group row width-50">
                                        <label class="col-3 control-label">{{trans('lang.user_phone')}}</label>
                                        <div class="col-7">
                                            <span class="phone"></span>
                                        </div>
                                    </div>
                                    <div class="form-group row width-50">
                                        <label class="col-3 control-label">{{trans('lang.wallet_Balance')}}</label>
                                        <div class="col-7 wallet_balance">
                                        </div>
                                    </div>

                                    <div class="form-group row width-50">
                                        <label class="col-3 control-label">{{trans('lang.profile_image')}}</label>
                                        <div class="col-7 profile_image">
                                        </div>
                                    </div>

                                    <div class="form-group row width-100">
                                        <label class="col-3 control-label">{{trans('lang.address')}}</label>
                                        <div class="col-7 address">
                                        </div>
                                    </div>

                                </fieldset>
                            </div>
                        </div>

                    </div>

                </div>
                <div class="form-group col-12 text-center btm-btn">
                    <a href="{!! route('users') !!}" class="btn btn-default"><i
                                class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
                </div>

            </div>
        </div>
    </div>

    <div class="modal fade" id="addWalletModal" tabindex="-1" role="dialog" aria-hidden="true">

        <div class="modal-dialog modal-dialog-centered location_modal">

            <div class="modal-content">

                <div class="modal-header">

                    <h5 class="modal-title locationModalTitle">{{trans('lang.add_wallet_amount')}}</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>

                </div>

                <div class="modal-body">

                    <form class="">

                        <div class="form-row">

                            <div class="form-group row">

                                <div class="form-group row width-100">
                                    <label class="col-12 control-label">{{trans('lang.amount')}}</label>
                                    <div class="col-12">

                                        <input type="number" name="amount" class="form-control" id="amount">

                                        <div id="wallet_error" style="color:red"></div>
                                    </div>
                                </div>

                                <div class="form-group row width-100">
                                    <label class="col-12 control-label">{{trans('lang.note')}}</label>
                                    <div class="col-12">
                                        <input type="text" name="note" class="form-control" id="note">
                                    </div>
                                </div>

                                <div class="form-group row width-100">

                                    <div id="user_account_not_found_error" class="align-items-center" style="color:red">
                                    </div>
                                </div>

                            </div>

                        </div>

                    </form>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" id="add-wallet-btn">{{trans('submit')}}</a>
                        </button>
                        <button type="button" class="btn btn-primary" data-dismiss="modal"
                                aria-label="Close">{{trans('close')}}</a>
                        </button>

                    </div>


                </div>
            </div>

        </div>

    </div>

@endsection

@section('scripts')
    <script>

        var id = "{{$id}}";
        var database = firebase.firestore();
        var ref = database.collection('users').where("id", "==", id);
        var photo = "";

        var placeholderImage = '';
        var placeholder = database.collection('settings').doc('placeHolderImage');

        placeholder.get().then(async function (snapshotsimage) {
            var placeholderImageData = snapshotsimage.data();
            placeholderImage = placeholderImageData.image;
        });

        var currentCurrency = '';
        var currencyAtRight = false;
        var decimal_degits = 0;

        var refCurrency = database.collection('currencies').where('isActive', '==', true);
        refCurrency.get().then(async function (snapshots) {
            var currencyData = snapshots.docs[0].data();
            currentCurrency = currencyData.symbol;
            currencyAtRight = currencyData.symbolAtRight;
            if (currencyData.decimal_degits) {
                decimal_degits = currencyData.decimal_degits;
            }
            $(".currentCurrency").text(currencyData.symbol);

        });


        var email_templates = database.collection('email_templates').where('type', '==', 'wallet_topup');

        var emailTemplatesData = null;

        $(document).ready(async function () {

            jQuery("#data-table_processing").show();

            await email_templates.get().then(async function (snapshots) {
                emailTemplatesData = snapshots.docs[0].data();
            });

            ref.get().then(async function (snapshots) {
                var user = snapshots.docs[0].data();

                $(".user_name").text(user.firstName + ' ' + user.lastName);

                if (user.hasOwnProperty('email') && user.email) {
                    $(".email").text(user.email);

                } else {
                    $('.email').html("{{trans('lang.not_mentioned')}}");

                }

                if (user.hasOwnProperty('phoneNumber') && user.phoneNumber) {
                    $(".phone").text(user.phoneNumber);

                } else {
                    $('.phone').html("{{trans('lang.not_mentioned')}}");

                }

                var wallet_balance = 0;

                if (user.hasOwnProperty('wallet_amount') && user.wallet_amount != null && !isNaN(user.wallet_amount)) {
                    wallet_balance = user.wallet_amount;
                }
                if (currencyAtRight) {
                    wallet_balance = parseFloat(wallet_balance).toFixed(decimal_degits) + "" + currentCurrency;
                } else {
                    wallet_balance = currentCurrency + "" + parseFloat(wallet_balance).toFixed(decimal_degits);
                }

                $('.wallet_balance').html(wallet_balance);

                var image = "";
                if (user.profilePictureURL) {
                    image = '<img width="100px" id="" height="auto" src="' + user.profilePictureURL + '">';
                } else {
                    image = '<img width="100px" id="" height="auto" src="' + placeholderImage + '">';
                }

                $('.profile_image').html(image);

                var address = '';
                if (user.hasOwnProperty('shippingAddress') && Array.isArray(user.shippingAddress)) {
                    shippingAddress = user.shippingAddress;
                    address+='<div id="append_list1" class="res-search-list row">';
                    shippingAddress.forEach((listval) => {
                        var defaultBtnHtml = '';

                        if (listval.isDefault == true) {
                            defaultBtnHtml = '<span class="badge badge-success ml-2 py-2 px-3" type="button" >Default</span>';
                        }

                        address = address + '<div class="transactions-list-wrap mt-4 col-md-6">';
                        address +='<div class="bg-white rounded-lg mb-3 transactions-list-view shadow-sm">';
                        address +='<div class="gold-members d-flex align-items-start transactions-list">';

                        address = address + '<div class="media transactions-list-left w-100">';
                        address = address + '<div class="media-body"><h6 class="date">' + listval.address + "," + listval.locality + " " + listval.landmark + '</h6>';

                        address = address + '<span class="badge badge-info py-2 px-3">' + listval.addressAs + '</span>' + defaultBtnHtml ;
                        address += '</div></div>';
                        address = address + '</div> </div></div>';    
                     });
                    address +='</div>';

                } 
                if (address != "") {
                    $('.address').html(address);
                } else {
                    $('.address').html("<h5>{{trans('lang.not_mentioned')}}</h5>");
                }

                jQuery("#data-table_processing").hide();

            });

        });

        $("#add-wallet-btn").click(function () {
            var date = firebase.firestore.FieldValue.serverTimestamp();
            var amount = $('#amount').val();
            if (amount == '') {
                $('#wallet_error').text('{{trans("lang.add_wallet_amount_error")}}')
                return false;
            }

            var note = $('#note').val();
            database.collection('users').where('id', '==', id).get().then(async function (snapshot) {

                if (snapshot.docs.length > 0) {
                    var data = snapshot.docs[0].data();
                    //console.log(data);

                    var walletAmount = 0;
                    if (data.hasOwnProperty('wallet_amount') && !isNaN(data.wallet_amount) && data.wallet_amount != null) {
                        walletAmount = data.wallet_amount;

                    }

                    var newWalletAmount = parseFloat(walletAmount) + parseFloat(amount);

                    database.collection('users').doc(id).update({
                        'wallet_amount': newWalletAmount
                    }).then(function (result) {
                        var tempId = database.collection("tmp").doc().id;
                        database.collection('wallet').doc(tempId).set({
                            'amount': parseFloat(amount),
                            'date': date,
                            'isTopUp': true,
                            'id': tempId,
                            'order_id': '',
                            'payment_method': 'Wallet',
                            'payment_status': 'success',
                            'user_id': id,
                            'note': note,
                            'transactionUser': "user",

                        }).then(async function (result) {

                            if (currencyAtRight) {
                                amount = parseInt(amount).toFixed(decimal_degits) + "" + currentCurrency;
                                newWalletAmount = newWalletAmount.toFixed(decimal_degits) + "" + currentCurrency;
                            } else {
                                amount = currentCurrency + "" + parseInt(amount).toFixed(decimal_degits);
                                newWalletAmount = currentCurrency + "" + newWalletAmount.toFixed(decimal_degits);
                            }

                            var formattedDate = new Date();
                            var month = formattedDate.getMonth() + 1;
                            var day = formattedDate.getDate();
                            var year = formattedDate.getFullYear();

                            month = month < 10 ? '0' + month : month;
                            day = day < 10 ? '0' + day : day;

                            formattedDate = day + '-' + month + '-' + year;

                            var message = emailTemplatesData.message;
                            message = message.replace(/{username}/g, data.firstName + ' ' + data.lastName);
                            message = message.replace(/{date}/g, formattedDate);
                            message = message.replace(/{amount}/g, amount);
                            message = message.replace(/{paymentmethod}/g, 'Wallet');
                            message = message.replace(/{transactionid}/g, tempId);
                            message = message.replace(/{newwalletbalance}/g, newWalletAmount);

                            emailTemplatesData.message = message;

                            var url = "{{url('send-email')}}";

                            var sendEmailStatus = await sendEmail(url, emailTemplatesData.subject, emailTemplatesData.message, [data.email]);

                            if (sendEmailStatus) {
                                window.location.reload();
                            }

                        })
                    })
                } else {
                    $('#user_account_not_found_error').text('{{trans("lang.user_detail_not_found")}}');
                }
            });

        });

    </script>
@endsection