@extends('layouts.app')

@section('content')

<div class="page-wrapper">

    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor">{{trans('lang.payout_request')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">

            <ol class="breadcrumb">

                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>

                <li class="breadcrumb-item active">{{trans('lang.payout_request')}}</li>

            </ol>

        </div>

    </div>


    <div class="container-fluid">

        <div class="row">

            <div class="col-12">

                <div class="card">

                    <div class="card-header">

                        <ul class="nav nav-tabs align-items-end card-header-tabs w-100">

                            <li class="nav-item">

                                <a class="nav-link" href="{!! url('payoutRequests/restaurants') !!}"><i

                                            class="fa fa-list mr-2"></i>{{trans('lang.restaurant_payout_request')}}</a>

                            </li>

                            <li class="nav-item">

                                <a class="nav-link active" href="{!! url('payoutRequests/drivers') !!}"><i

                                            class="fa fa-list mr-2"></i>{{trans('lang.drivers_payout_request')}}</a>

                            </li>

                        </ul>

                    </div>

                    <div class="card-body">

                        <div id="data-table_processing" class="dataTables_processing panel panel-default"

                             style="display: none;">{{trans('lang.processing')}}

                        </div>

                        <!--  <div id="users-table_filter" class="pull-right"><label>{{trans('lang.search_by')}}

                              <select name="selected_search" id="selected_search" class="form-control input-sm">

                                  <option value="note">{{ trans('lang.drivers_payout_note')}}</option>

                              </select>

                              <div class="form-group">

                                  <input type="search" id="search" class="search form-control" placeholder="Search"

                                  aria-controls="users-table">

                              </label>&nbsp;<button onclick="searchtext();" class="btn btn-warning btn-flat">

                                  {{trans('lang.search')}}

                              </button>&nbsp;<button onclick="searchclear();" class="btn btn-warning btn-flat">

                                  {{trans('lang.clear')}}

                              </button>

                          </div>

                      </div>-->


                        <div class="table-responsive m-t-10">

                            <table id="payoutRequestTable"

                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"

                                   cellspacing="0" width="100%">

                                <thead>

                                <tr>
                                    <?php if ($id == "") { ?>
                                        <th>{{ trans('lang.driver')}}</th>

                                    <?php } ?>

                                    <th>{{trans('lang.paid_amount')}}</th>

                                    <th>{{trans('lang.drivers_payout_note')}}</th>

                                    <th>{{trans('lang.drivers_payout_paid_date')}}</th>

                                    <th>{{trans('lang.status')}}</th>

                                    <th>{{trans('lang.actions')}}</th>

                                </tr>


                                </thead>


                                <tbody id="append_list1">


                                </tbody>


                            </table>

                            <!-- <nav aria-label="Page navigation example">

                               <ul class="pagination justify-content-center">

                                   <li class="page-item ">

                                       <a class="page-link" href="javascript:void(0);" id="users_table_previous_btn"

                                       onclick="prev()" data-dt-idx="0" tabindex="0">{{trans('lang.previous')}}</a>

                                   </li>

                                   <li class="page-item">

                                       <a class="page-link" href="javascript:void(0);" id="users_table_next_btn"

                                       onclick="next()" data-dt-idx="2" tabindex="0">{{trans('lang.next')}}</a>

                                   </li>

                               </ul>

                           </nav>-->

                        </div>


                    </div>


                </div>


            </div>


        </div>


    </div>


</div>

<div class="modal fade" id="bankdetailsModal" tabindex="-1" role="dialog"
     aria-hidden="true">

    <div class="modal-dialog modal-dialog-centered location_modal">

        <div class="modal-content">

            <div class="modal-header">

                <h5 class="modal-title locationModalTitle">{{trans('lang.bankdetails')}}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>

            </div>

            <div class="modal-body">

                <form class="">

                    <div class="form-row">

                        <input type="hidden" name="driverId" id="driverId">

                        <div class="form-group row">

                            <div class="form-group row width-100">
                                <label class="col-12 control-label">{{
                                    trans('lang.bank_name')}}</label>
                                <div class="col-12">
                                    <input type="text" name="bank_name" class="form-control" id="bankName">
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-12 control-label">{{
                                    trans('lang.branch_name')}}</label>
                                <div class="col-12">
                                    <input type="text" name="branch_name" class="form-control" id="branchName">
                                </div>
                            </div>


                            <div class="form-group row width-100">
                                <label class="col-4 control-label">{{
                                    trans('lang.holer_name')}}</label>
                                <div class="col-12">
                                    <input type="text" name="holer_name" class="form-control" id="holderName">
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-12 control-label">{{
                                    trans('lang.account_number')}}</label>
                                <div class="col-12">
                                    <input type="text" name="account_number" class="form-control" id="accountNumber">
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-12 control-label">{{
                                    trans('lang.other_information')}}</label>
                                <div class="col-12">
                                    <input type="text" name="other_information" class="form-control" id="otherDetails">
                                </div>
                            </div>

                        </div>

                    </div>

                </form>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal" aria-label="Close">
                        {{trans('close')}}</a>
                    </button>

                </div>
            </div>
        </div>

    </div>

</div>

@endsection

@section('scripts')

<script>

    var database = firebase.firestore();

    var offest = 1;

    var pagesize = 10;

    var end = null;

    var endarray = [];

    var start = null;

    var user_number = [];
    var driverId = "{{$id}}";
    var intRegex = /^\d+$/;
    var floatRegex = /^((\d+(\.\d *)?)|((\d*\.)?\d+))$/;

    if ('<?php echo $id?>' != "") {
        var refData = database.collection('driver_payouts').where('driverID', '==', '<?php echo $id?>');

    } else {
        var refData = database.collection('driver_payouts').where('paymentStatus', '==', 'Pending');


    }


    var email_templates = database.collection('email_templates').where('type', '==', 'payout_request_status');

    var emailTemplatesData = null;


    var ref = refData.orderBy('paidDate', 'desc');

    var append_list = '';


    var currentCurrency = '';

    var currencyAtRight = false;
    var decimal_degits = 0;

    var refCurrency = database.collection('currencies').where('isActive', '==', true);

    refCurrency.get().then(async function (snapshots) {

        var currencyData = snapshots.docs[0].data();

        currentCurrency = currencyData.symbol;

        currencyAtRight = currencyData.symbolAtRight;

        currencyAtRight = currencyData.symbolAtRight;

        if (currencyData.decimal_degits) {
            decimal_degits = currencyData.decimal_degits;
        }


    });


    $(document).ready(function () {


        email_templates.get().then(async function (snapshots) {
            emailTemplatesData = snapshots.docs[0].data();

        });

        $(document.body).on('click', '.redirecttopage', function () {

            var url = $(this).attr('data-url');

            window.location.href = url;

        });


        var inx = parseInt(offest) * parseInt(pagesize);

        jQuery("#data-table_processing").show();


        append_list = document.getElementById('append_list1');

        append_list.innerHTML = '';

        ref.get().then(async function (snapshots) {

            html = '';


            html = await buildHTML(snapshots);


            if (html != '') {

                append_list.innerHTML = html;

                start = snapshots.docs[snapshots.docs.length - 1];

                endarray.push(snapshots.docs[0]);

                if (snapshots.docs.length < pagesize) {

                    jQuery("#data-table_paginate").hide();

                }

            }
            if (driverId == '') {
                $('#payoutRequestTable').DataTable({
                    order: [],
                    columnDefs: [
                        {
                            targets: 3,
                            type: 'date',
                            render: function (data) {

                                return data;
                            }
                        },
                        {orderable: false, targets: [5]},
                    ],
                    order: [['3', 'desc']],
                    "language": {
                        "zeroRecords": "{{trans("lang.no_record_found")}}",
                        "emptyTable": "{{trans("lang.no_record_found")}}"
                    },
                    responsive: true
                });

            } else {
                $('#payoutRequestTable').DataTable({
                    order: [],
                    columnDefs: [
                        {
                            targets: 2,
                            type: 'date',
                            render: function (data) {

                                return data;
                            }
                        },
                        {orderable: false, targets: [4]},
                    ],
                    order: [['2', 'desc']],
                    "language": {
                        "zeroRecords": "{{trans("lang.no_record_found")}}",
                        "emptyTable": "{{trans("lang.no_record_found")}}"
                    },
                    responsive: true
                });

            }

            jQuery("#data-table_processing").hide();

        });


    });


    function buildHTML(snapshots) {

        var html = '';

        var alldata = [];

        var number = [];

        snapshots.docs.forEach((listval) => {

            var datas = listval.data();

            datas.id = listval.id;

            alldata.push(datas);

        });


        alldata.forEach((listval) => {


            var val = listval;

            var route1 = '{{route("drivers.edit",":id")}}';

            route1 = route1.replace(':id', val.id);

            html = html + '<tr>';


            if ('<?php echo $id?>' == "") {
                const payoutDriver = payoutDriverfunction(val.driverID);

                html = html + '<td class="driver_' + val.driverID + ' redirecttopage" ></td>';

            }

            var price_val = '';
            var price = val.amount;

            if (intRegex.test(price) || floatRegex.test(price)) {

                price = parseFloat(price).toFixed(2);
            } else {
                price = 0;
            }

            if (currencyAtRight) {
                price_val = parseFloat(price).toFixed(decimal_degits) + "" + currentCurrency;
            } else {
                price_val = currentCurrency + "" + parseFloat(price).toFixed(decimal_degits);
            }

            html = html + '<td>' + price_val + '</td>';


            var date = val.paidDate.toDate().toDateString();

            var time = val.paidDate.toDate().toLocaleTimeString('en-US');

            if (val.note) {
                html = html + '<td>' + val.note + '</td>';

            } else {
                html = html + '<td></td>';

            }
            html = html + '<td class="dt-time">' + date + ' ' + time + '</td>';


            if (val.paymentStatus) {
                html = html + '<td>' + val.paymentStatus + '</td>';

            } else {
                html = html + '<td></td>';

            }


            html = html + '<td class="action-btn"><a id="' + val.id + '" name="driver_view" data-auth="' + val.driverID + '" href="javascript:void(0)" data-toggle="modal" data-target="#bankdetailsModal"><i class="fa fa-eye"></i></a><a id="' + val.id + '" name="driver_check" data-auth="' + val.driverID + '" amount="' + price_val + '" href="javascript:void(0)"><i class="fa fa-check"></i></a><a id="' + val.id + '" data-price="' + val.amount + '" amount = "' + price_val + '"  name="reject-request" data-auth="' + val.driverID + '" href="javascript:void(0)"><i class="fa fa-close" ></i></a></td>';


            html = html + '</tr>';


        });

        return html;

    }


    async function getDriverBankDetails() {
        var driverId = $('#driverId').val();

        await database.collection('users').where("id", "==", driverId).get().then(async function (snapshotss) {

            if (snapshotss.docs[0]) {
                var user_data = snapshotss.docs[0].data();
                if (user_data.userBankDetails) {

                    $('#bankName').val(user_data.userBankDetails.bankName);
                    $('#branchName').val(user_data.userBankDetails.branchName);
                    $('#holderName').val(user_data.userBankDetails.holderName);
                    $('#accountNumber').val(user_data.userBankDetails.accountNumber);
                    $('#otherDetails').val(user_data.userBankDetails.otherDetails);

                }

            }
        });

    }

    $(document).on("click", "a[name='driver_view']", function (e) {
        $('#bankName').val("");
        $('#branchName').val("");
        $('#holderName').val("");
        $('#accountNumber').val("");
        $('#otherDetails').val("");

        var id = this.id;
        var auth = $(this).attr('data-auth');
        $('#driverId').val(auth);
        getDriverBankDetails();

    });

    async function payoutDriverfunction(driver) {


        console.log(driver);

        var payoutDriver = '';

        var routedriver = '{{route("users.edit",":id")}}';

        routedriver = routedriver.replace(':id', driver);

        await database.collection('users').where("id", "==", driver).get().then(async function (snapshotss) {


            if (snapshotss.docs[0]) {

                var driver_data = snapshotss.docs[0].data();

                payoutDriver = driver_data.firstName + " " + driver_data.lastName;

                jQuery(".driver_" + driver).attr("data-url", routedriver).html(payoutDriver);

            } else {

                jQuery(".driver_" + driver).attr("data-url", routedriver).html('');

            }

        });

        return payoutDriver;

    }


    $(document).on("click", "a[name='driver_check']", async function (e) {

        var id = this.id;

        var fullname = $(this).attr('data-name');

        var auth = $(this).attr('data-auth');

        var amount = $(this).attr('amount');

        var user = await getUserData(auth);

        jQuery("#data-table_processing").show().html("{{trans('lang.saving')}}");

        database.collection('driver_payouts').doc(id).update({'paymentStatus': 'Success'}).then(async function (result) {

            if (user && user != undefined) {

                var emailData = await sendMailToRestaurant(user, id, 'Approved', amount);

                if (emailData) {
                    window.location.reload();
                }
            } else {
                window.location.reload();
            }
        });

    });

    async function sendMailToRestaurant(user, id, status, amount) {

        var formattedDate = new Date();
        var month = formattedDate.getMonth() + 1;
        var day = formattedDate.getDate();
        var year = formattedDate.getFullYear();

        month = month < 10 ? '0' + month : month;
        day = day < 10 ? '0' + day : day;

        formattedDate = day + '-' + month + '-' + year;

        var subject = emailTemplatesData.subject;

        subject = subject.replace(/{requestid}/g, id);
        emailTemplatesData.subject = subject;

        var message = emailTemplatesData.message;
        message = message.replace(/{username}/g, user.firstName + ' ' + user.lastName);
        message = message.replace(/{date}/g, formattedDate);
        message = message.replace(/{requestid}/g, id);
        message = message.replace(/{status}/g, status);
        message = message.replace(/{amount}/g, amount);
        message = message.replace(/{usercontactinfo}/g, user.phoneNumber);

        emailTemplatesData.message = message;

        var url = "{{url('send-email')}}";

        return await sendEmail(url, emailTemplatesData.subject, emailTemplatesData.message, [user.email]);
    }

    async function getUserData(driverId) {
        var data = '';

        await database.collection('users').where("id", "==", driverId).get().then(async function (snapshotss) {

            if (snapshotss.docs[0]) {
                data = snapshotss.docs[0].data();
            }
        });

        return data;
    }


    $(document).on("click", "a[name='reject-request']", async function (e) {
        var id = this.id;
        var auth = $(this).attr('data-auth');

        var user = await getUserData(auth);

        var priceadd = $(this).attr('data-price');
        var amount = $(this).attr('amount');

        jQuery("#data-table_processing").show().html("{{trans('lang.saving')}}");
        database.collection('users').where("id", "==", auth).get().then(function (resultvendor) {
            if (resultvendor.docs.length) {
                var vendor = resultvendor.docs[0].data();
                var wallet_amount = 0;
                if (isNaN(vendor.wallet_amount) || vendor.wallet_amount == undefined) {
                    wallet_amount = 0;
                } else {
                    wallet_amount = vendor.wallet_amount;
                }

                price = parseFloat(wallet_amount) + parseFloat(priceadd);
                if (!isNaN(price)) {
                    database.collection('driver_payouts').doc(id).update({'paymentStatus': 'Reject'}).then(function (result) {
                        database.collection('users').doc(vendor.id).update({'wallet_amount': price}).then(async function (result) {

                            if (user && user != undefined) {

                                var emailData = await sendMailToRestaurant(user, id, 'Disapproved', amount);

                                if (emailData) {
                                    window.location.reload();
                                }
                            } else {
                                window.location.reload();
                            }
                        });
                    });
                }
            } else {
                alert('Driver not found.');
            }
        });
    });

    function prev() {

        if (endarray.length == 1) {

            return false;

        }

        end = endarray[endarray.length - 2];


        if (end != undefined || end != null) {

            jQuery("#data-table_processing").show();


            if (jQuery("#selected_search").val() == 'vendor' && jQuery("#search").val().trim() != '') {

                listener = refData.orderBy('firstName').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();


            } else {

                listener = ref.startAt(end).limit(pagesize).get();

            }


            listener.then((snapshots) => {

                html = '';

                html = buildHTML(snapshots);

                jQuery("#data-table_processing").hide();

                if (html != '') {

                    append_list.innerHTML = html;

                    start = snapshots.docs[snapshots.docs.length - 1];

                    endarray.splice(endarray.indexOf(endarray[endarray.length - 1]), 1);


                    if (snapshots.docs.length < pagesize) {


                        jQuery("#users_table_previous_btn").hide();

                    }


                }

            });

        }

    }


    function next() {

        if (start != undefined || start != null) {


            jQuery("#data-table_processing").hide();

            if (jQuery("#selected_search").val() == 'vendor' && jQuery("#search").val().trim() != '') {


                listener = refData.orderBy('firstName').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();


            } else {

                listener = ref.startAfter(start).limit(pagesize).get();

            }

            listener.then((snapshots) => {


                html = '';

                html = buildHTML(snapshots);

                console.log(snapshots);

                jQuery("#data-table_processing").hide();

                if (html != '') {

                    append_list.innerHTML = html;

                    start = snapshots.docs[snapshots.docs.length - 1];


                    if (endarray.indexOf(snapshots.docs[0]) != -1) {

                        endarray.splice(endarray.indexOf(snapshots.docs[0]), 1);

                    }

                    endarray.push(snapshots.docs[0]);

                }

            });

        }

    }


    function searchclear() {

        jQuery("#search").val('');

        searchtext();

    }


    function searchtext() {


        jQuery("#data-table_processing").show();


        append_list.innerHTML = '';


        if (jQuery("#selected_search").val() == 'note' && jQuery("#search").val().trim() != '') {


            wherequery = refData.orderBy('note').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();


        } else {


            wherequery = ref.limit(pagesize).get();

        }


        wherequery.then((snapshots) => {

            html = '';

            html = buildHTML(snapshots);

            jQuery("#data-table_processing").hide();

            if (html != '') {

                append_list.innerHTML = html;

                start = snapshots.docs[snapshots.docs.length - 1];

                endarray.push(snapshots.docs[0]);

                /*if(snapshots.docs.length<pagesize && jQuery("#selected_search").val().trim()!='' && jQuery("#search").val().trim()!=''){*/

                if (snapshots.docs.length < pagesize) {


                    jQuery("#data-table_paginate").hide();

                } else {


                    jQuery("#data-table_paginate").show();

                }

            }

        });

    }

</script>

@endsection

