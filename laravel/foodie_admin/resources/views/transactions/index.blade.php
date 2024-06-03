@extends('layouts.app')

@section('content')

<div class="page-wrapper">


    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor">{{trans('lang.wallet_transaction_plural')}} <span class="userTitle"></span>
            </h3>

        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item active">{{trans('lang.wallet_transaction_plural')}}</li>
            </ol>
        </div>

        <div>

        </div>

    </div>


    <div class="container-fluid">

        <div class="row">

            <div class="col-12">

                <div class="card">
                    <div class="card-header">
                        <ul class="nav nav-tabs align-items-end card-header-tabs w-100">
                            <li class="nav-item">
                                <a class="nav-link active" href="{!! url()->current() !!}"><i
                                            class="fa fa-list mr-2"></i>{{trans('lang.wallet_transaction_table')}}
                                </a>
                            </li>

                        </ul>
                    </div>
                    <div class="card-body">
                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">{{trans('lang.processing')}}
                        </div>

                        <!--<div id="users-table_filter" class="pull-right"><label>{{trans('lang.search_by')}}
                                <select name="selected_search" id="selected_search" class="form-control input-sm">
                                    <option value="user">{{ trans('lang.food_review_user_id')}}</option>
                                    <option value="payment_status">{{ trans('lang.payment_status')}}</option>
                                </select>
                                <div class="form-group">
                                    <input type="search" id="search" class="search form-control"
                                           placeholder="Search"
                                           aria-controls="users-table">
                            </label>&nbsp;<button onclick="searchtext();" class="btn btn-warning btn-flat">
                                {{trans('lang.search')}}
                            </button>&nbsp;<button onclick="searchclear();" class="btn btn-warning btn-flat">
                                {{trans('lang.clear')}}
                            </button>
                        </div>
                    </div>-->


                        <div class="table-responsive m-t-10">


                            <table id="walletTransactionTable"
                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                   cellspacing="0" width="100%">

                                <thead>

                                <tr>
                                    <?php if ($id == '') { ?>
                                        <th>{{ trans('lang.users')}}</th>
                                        <th>{{ trans('lang.role')}}</th>
                                    <?php } ?>
                                    <th>{{trans('lang.amount')}}</th>
                                    <th>{{trans('lang.date')}}</th>
                                    <th>{{trans('lang.wallet_transaction_note')}}</th>
                                    <th>{{trans('lang.payment_method')}}</th>
                                    <th>{{trans('lang.payment_status')}}</th>
                                </tr>

                                </thead>

                                <tbody id="append_list1">


                                </tbody>

                            </table>
                            <!--<nav aria-label="Page navigation example">
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

    var refData = database.collection('wallet');
    var search = jQuery("#search").val();

    $(document.body).on('keyup', '#search', function () {
        search = jQuery(this).val();
    });

    <?php if($id != ''){ ?>

    ref = refData.where('user_id', '==', '<?php echo $id; ?>').orderBy('date', 'desc');
    <?php }else{ ?>

    ref = refData.orderBy('date', 'desc');

    <?php } ?>

    var append_list = '';

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
    });

    $(document).ready(function () {

        if ('{{$id}}') {
            var username = database.collection('users').where('id', '==', '{{$id}}');
            username.get().then(async function (snapshots) {
                var username = snapshots.docs[0].data();
                $(".userTitle").text(' of ' + username.firstName + " " + username.lastName);
            });
        }

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
            console.log(snapshots.docs.length);
            if (snapshots.docs.length > 0) {
                html = await buildHTML(snapshots);
            }

            if (html != '') {
                append_list.innerHTML = html;
                start = snapshots.docs[snapshots.docs.length - 1];
                endarray.push(snapshots.docs[0]);
                if (snapshots.docs.length < pagesize) {
                    jQuery("#data-table_paginate").hide();
                }
            }


            $('#walletTransactionTable').DataTable({
                order: [],
                columnDefs: [
                    {
                        targets: 3,
                        type: 'date',
                        render: function (data) {

                            return data;
                        }
                    },
                    {orderable: false, targets: [3, 4]},
                ],
                order: [['3', 'desc']],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                responsive: true
            });
            jQuery("#data-table_processing").hide();
        });

    });

    async function buildHTML(snapshots) {
        var html = '';

        await Promise.all(snapshots.docs.map(async (listval) => {

            var val = listval.data();

            var getData = await getWalletTransactionListData(val);
            html += getData;
        }));

        return html;
    }


    async function getWalletTransactionListData(val) {
        var html = '';

        html = html + '<tr>';

        <?php if($id == ''){ ?>
        if (val.user_id) {
            var payoutuser = await payoutuserfunction(val.user_id);

            if (payoutuser != '') {

                var user_role = payoutuser.role;
                var user_name = '';

                if (payoutuser.hasOwnProperty('firstName')) {
                    user_name = payoutuser.firstName;
                }

                if (payoutuser.hasOwnProperty('lastName')) {
                    user_name = user_name + ' ' + payoutuser.lastName;
                }

                var routeuser = "Javascript:void(0)";
                if (user_role == "customer") {
                    routeuser = '{{route("users.edit",":id")}}';
                    routeuser = routeuser.replace(':id', val.user_id);
                } else if (user_role == "driver") {
                    routeuser = '{{route("drivers.edit",":id")}}';
                    routeuser = routeuser.replace(':id', val.user_id);
                } else if (user_role == "vendor") {

                    if (payoutuser.vendorID != '') {
                        routeuser = '{{route("restaurants.edit",":id")}}';
                        routeuser = routeuser.replace(':id', payoutuser.vendorID);
                    }

                }
                html = html + '<td class="user_' + val.user_id + '"><a href="' + routeuser + '">' + user_name + '</a></td>';
                html = html + '<td class="user_role_' + val.user_id + '" >' + user_role + '</td>';
            } else {
                html = html + '<td></td><td></td>';

            }

        } else {
            html = html + '<td></td><td></td>';
        }
        <?php } ?>
        amount = val.amount;
        if (!isNaN(amount)) {
            amount = parseFloat(amount).toFixed(decimal_degits);

        }

        if ((val.hasOwnProperty('isTopUp') && val.isTopUp) || (val.payment_method == "Cancelled Order Payment")) {

            if (currencyAtRight) {

                html = html + '<td class="text-green">' + parseFloat(amount).toFixed(decimal_degits) + '' + currentCurrency + '</td>';


            } else {
                html = html + '<td class="text-green">' + currentCurrency + '' + parseFloat(amount).toFixed(decimal_degits) + '</td>';
            }

        } else if (val.hasOwnProperty('isTopUp') && !val.isTopUp) {

            if (currencyAtRight) {
                html = html + '<td class="text-red">(-' + parseFloat(amount).toFixed(decimal_degits) + '' + currentCurrency + ')</td>';

            } else {
                html = html + '<td class="text-red">(-' + currentCurrency + '' + parseFloat(amount).toFixed(decimal_degits) + ')</td>';
            }

        } else {
            if (currencyAtRight) {
                html = html + '<td class="">' + parseFloat(amount).toFixed(decimal_degits) + '' + currentCurrency + '</td>';

            } else {
                html = html + '<td class="">' + currentCurrency + '' + parseFloat(amount).toFixed(decimal_degits) + '</td>';
            }
        }


        var date = "";
        var time = "";
        try {
            if (val.hasOwnProperty("date")) {
                date = val.date.toDate().toDateString();
                time = val.date.toDate().toLocaleTimeString('en-US');
            }
        } catch (err) {

        }


        html = html + '<td>' + date + ' ' + time + '</td>';
        if (val.note != undefined && val.note != '') {
            html = html + '<td>' + val.note + '</td>';
        } else {
            html = html + '<td></td>';
        }

        var payment_method = '';
        if (val.payment_method) {

            if (val.payment_method == "Stripe") {
                image = '{{asset("images/stripe.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "RazorPay") {
                image = '{{asset("images/razorepay.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Paypal") {
                image = '{{asset("images/paypal.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "PayFast") {
                image = '{{asset("images/payfast.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "PayStack") {
                image = '{{asset("images/paystack.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "FlutterWave") {
                image = '{{asset("images/flutter_wave.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Mercado Pago") {
                image = '{{asset("images/marcado_pago.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Wallet") {
                image = '{{asset("images/foodie_wallet.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Paytm") {
                image = '{{asset("images/paytm.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Cancelled Order Payment") {
                image = '{{asset("images/cancel_order.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';

            } else if (val.payment_method == "Refund Amount") {
                image = '{{asset("images/refund_amount.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';
            } else if (val.payment_method == "Referral Amount") {
                image = '{{asset("images/reffral_amount.png")}}';
                payment_method = '<img alt="image" src="' + image + '" >';
            } else {
                payment_method = val.payment_method;
            }
        }

        html = html + '<td class="payment_images">' + payment_method + '</td>';

        if (val.payment_status == 'success') {
            html = html + '<td class="success"><span>' + val.payment_status + '</span></td>';
        } else if (val.payment_status == 'undefined') {
            html = html + '<td class="undefined"><span>' + val.payment_status + '</span></td>';
        } else if (val.payment_status == 'Refund success') {
            html = html + '<td class="refund_success"><span>' + val.payment_status + '</span></td>';

        } else {
            html = html + '<td class="refund_success"><span>' + val.payment_status + '</span></td>';

        }

        html = html + '</tr>';
        return html;
    }

    function prev() {
        if (endarray.length == 1) {
            return false;
        }
        end = endarray[endarray.length - 2];

        if (end != undefined || end != null) {
            jQuery("#data-table_processing").show();


            if (jQuery("#selected_search").val() == 'payment_status' && jQuery("#search").val().trim() != '') {
                listener = ref.orderBy('payment_status').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();

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
            } else if (jQuery("#selected_search").val() == 'user' && jQuery("#search").val().trim() != '') {

                var vendors = database.collection('users').orderBy('firstName').startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

                vendors.then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var data = snapshots.docs[0].data();

                        listener = refData.orderBy('user_id').limit(pagesize).startAt(data.id).endAt(data.id + '\uf8ff').startAfter(start).get();

                        listener.then((snapshotsInner) => {
                            html = '';
                            html = buildHTML(snapshotsInner);
                            jQuery("#data-table_processing").hide();

                            if (html != '') {
                                append_list.innerHTML = html;
                                start = snapshotsInner.docs[snapshotsInner.docs.length - 1];
                                endarray.splice(endarray.indexOf(endarray[endarray.length - 1]), 1);

                                if (snapshotsInner.docs.length < pagesize) {

                                    jQuery("#users_table_previous_btn").hide();
                                }

                            }
                        });
                    }
                });

            } else {
                listener = ref.startAt(end).limit(pagesize).get();
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
    }

    function next() {
        if (start != undefined || start != null) {

            jQuery("#data-table_processing").hide();
            if (jQuery("#selected_search").val() == 'payment_status' && jQuery("#search").val().trim() != '') {

                listener = ref.orderBy('payment_status').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();
                listener.then((snapshots) => {

                    html = '';
                    html = buildHTML(snapshots);
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

            } else if (jQuery("#selected_search").val() == 'user' && jQuery("#search").val().trim() != '') {

                var vendors = database.collection('users').orderBy('firstName').startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

                vendors.then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var data = snapshots.docs[0].data();

                        listener = refData.orderBy('user_id').limit(pagesize).startAt(data.id).endAt(data.id + '\uf8ff').startAfter(start).get();

                        listener.then((snapshotsInner) => {
                            html = '';
                            html = buildHTML(snapshotsInner);
                            jQuery("#data-table_processing").hide();

                            if (html != '') {
                                append_list.innerHTML = html;
                                start = snapshotsInner.docs[snapshotsInner.docs.length - 1];
                                endarray.splice(endarray.indexOf(endarray[endarray.length - 1]), 1);

                                if (snapshotsInner.docs.length < pagesize) {

                                    jQuery("#users_table_previous_btn").hide();
                                }

                            }
                        });
                    }
                });
            } else {
                listener = ref.startAfter(start).limit(pagesize).get();
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
    }

    function searchclear() {
        jQuery("#search").val('');
        searchtext();
    }


    function searchtext() {

        jQuery("#data-table_processing").show();

        append_list.innerHTML = '';

        if (jQuery("#selected_search").val() == 'payment_status' && jQuery("#search").val().trim() != '') {

            wherequery = refData.orderBy('payment_status').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

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

        } else if (jQuery("#selected_search").val() == 'user' && jQuery("#search").val().trim() != '') {

            var vendors = database.collection('users').orderBy('firstName').startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

            vendors.then(async function (snapshots) {

                if (snapshots.docs.length > 0) {
                    var data = snapshots.docs[0].data();

                    wherequery = refData.orderBy('user_id').limit(pagesize).startAt(data.id).endAt(data.id + '\uf8ff').get();

                    wherequery.then((snapshotsInner) => {
                        html = '';
                        html = buildHTML(snapshotsInner);
                        jQuery("#data-table_processing").hide();

                        if (html != '') {
                            append_list.innerHTML = html;
                            start = snapshotsInner.docs[snapshotsInner.docs.length - 1];
                            endarray.splice(endarray.indexOf(endarray[endarray.length - 1]), 1);

                            if (snapshotsInner.docs.length < pagesize) {

                                jQuery("#users_table_previous_btn").hide();
                            }

                        }
                    });
                }
            });
        } else {

            wherequery = ref.limit(pagesize).get();

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


    }


    async function payoutuserfunction(user) {
        var payoutuser = '';

        await database.collection('users').where("id", "==", user).get().then(async function (snapshotss) {

            if (snapshotss.docs[0]) {
                payoutuser = snapshotss.docs[0].data();
            }
        });
        return payoutuser;
    }
</script>


@endsection
