@extends('layouts.app')

@section('content')
<div class="page-wrapper">


    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor driverName">{{trans('lang.drivers_payout_plural')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item active">{{trans('lang.drivers_payout_plural')}}</li>
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
                                            class="fa fa-list mr-2"></i>{{trans('lang.drivers_payout_table')}}</a>
                            </li>

                            <?php if ($id != '') { ?>
                                <li class="nav-item">
                                    <a class="nav-link" href="{!! route('driver.payout.create',$id) !!}/"><i
                                                class="fa fa-plus mr-2"></i>{{trans('lang.drivers_payout_create')}}</a>
                                </li>
                            <?php } else { ?>
                                <li class="nav-item">
                                    <a class="nav-link" href="{!! route('driversPayouts.create') !!}"><i
                                                class="fa fa-plus mr-2"></i>{{trans('lang.drivers_payout_create')}}</a>
                                </li>
                            <?php } ?>

                        </ul>
                    </div>
                    <div class="card-body">
                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">{{trans('lang.processing')}}
                        </div>

                        <!--<div id="users-table_filter" class="pull-right"><label>{{trans('lang.search_by')}}
                                <select name="selected_search" id="selected_search" class="form-control input-sm">
                                    <option value="note">{{ trans('lang.drivers_payout_note')}}</option>
                                    <option value="driver">{{ trans('lang.driver')}}</option>
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


                            <table id="driverPayoutTable"
                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                   cellspacing="0" width="100%">

                                <thead>

                                <tr>
                                    <th>{{ trans('lang.driver')}}</th>
                                    <th>{{trans('lang.paid_amount')}}</th>

                                    <th>{{trans('lang.drivers_payout_paid_date')}}</th>
                                    <th>{{trans('lang.drivers_payout_note')}}</th>
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

    var driver_id = "<?php echo $id; ?>";

    var database = firebase.firestore();
    var offest = 1;
    var pagesize = 10;
    var end = null;
    var endarray = [];
    var start = null;
    var user_number = [];
    if (driver_id) {
        getDriverName(driver_id);
        var refData = database.collection('driver_payouts').where('driverID', '==', driver_id).where('paymentStatus', '==', 'Success');
    } else {
        var refData = database.collection('driver_payouts').where('paymentStatus', '==', 'Success');
    }
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

        if (currencyData.decimal_degits) {
            decimal_degits = currencyData.decimal_degits;
        }
    });

    $(document).ready(function () {

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

            $('#driverPayoutTable').DataTable({
                order: [],
                columnDefs: [
                    {
                        targets: 2,
                        type: 'date',
                        render: function (data) {

                            return data;
                        }
                    },
                    {orderable: false, targets: [0]},
                ],
                order: [['2', 'desc']],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                responsive: true
            });

            jQuery("#data-table_processing").hide();
        });

    });

    async function getDriverName(driver_id) {
        var usersnapshots = await database.collection('users').doc(driver_id).get();
        var driverData = usersnapshots.data();
        if (driverData) {
            var driverName = driverData.firstName + ' ' + driverData.lastName;
            $('.driverName').html('{{trans("lang.drivers_payout_plural")}} - ' + driverName);
        }
    }

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

            const payoutDriver = payoutDriverfunction(val.driverID);
            html = html + '<td class="driver_' + val.driverID + ' redirecttopage" ></td>';

            if (currencyAtRight) {
                html = html + '<td class="text-red">(' + parseFloat(val.amount).toFixed(decimal_degits) + '' + currentCurrency + ')</td>';
            } else {
                html = html + '<td class="text-red">(' + currentCurrency + '' + parseFloat(val.amount).toFixed(decimal_degits) + ')</td>';
            }
            var date = val.paidDate.toDate().toDateString();
            var time = val.paidDate.toDate().toLocaleTimeString('en-US');
            html = html + '<td>' + date + ' ' + time + '</td>';
            html = html + '<td>' + val.note + '</td>';

            html = html + '</tr>';

        });
        return html;
    }

    function prev() {
        if (endarray.length == 1) {
            return false;
        }
        end = endarray[endarray.length - 2];

        if (end != undefined || end != null) {

            jQuery("#data-table_processing").show();


            if (jQuery("#selected_search").val() == 'note' && jQuery("#search").val().trim() != '') {
                listener = refData.orderBy('note').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();

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
            } else if (jQuery("#selected_search").val() == 'driver' && jQuery("#search").val().trim() != '') {
                title = jQuery("#search").val();

                database.collection('users').where('firstName', '==', title).get().then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var driverdata = snapshots.docs[0].data();

                        listener = refData.orderBy('driverID').limit(pagesize).startAt(driverdata.id).endAt(driverdata.id + '\uf8ff').startAt(end).get();

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
            if (jQuery("#selected_search").val() == 'note' && jQuery("#search").val().trim() != '') {

                listener = refData.orderBy('note').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();

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
            } else if (jQuery("#selected_search").val() == 'driver' && jQuery("#search").val().trim() != '') {
                title = jQuery("#search").val();

                database.collection('users').where('firstName', '==', title).get().then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var driverdata = snapshots.docs[0].data();

                        listener = refData.orderBy('driverID').limit(pagesize).startAt(driverdata.id).endAt(driverdata.id + '\uf8ff').startAt(end).get();

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

        if (jQuery("#selected_search").val() == 'note' && jQuery("#search").val().trim() != '') {

            wherequery = refData.orderBy('note').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();
            wherequery.then((snapshots) => {
                html = '';
                html = buildHTML(snapshots);
                jQuery("#data-table_processing").hide();
                if (html != '') {
                    append_list.innerHTML = html;
                    start = snapshots.docs[snapshots.docs.length - 1];
                    endarray.push(snapshots.docs[0]);
                    if (snapshots.docs.length < pagesize) {

                        jQuery("#data-table_paginate").hide();
                    } else {

                        jQuery("#data-table_paginate").show();
                    }
                }
            });
        } else if (jQuery("#selected_search").val() == 'driver' && jQuery("#search").val().trim() != '') {
            title = jQuery("#search").val();

            var vendors = database.collection('users').orderBy('firstName').startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();
            vendors.then(async function (snapshots) {
                if (snapshots.docs.length > 0) {
                    var driverdata = snapshots.docs[0].data();
                    console.log(driverdata.id);
                    wherequery = refData.orderBy('driverID').limit(pagesize).startAt(driverdata.id).endAt(driverdata.id + '\uf8ff').get();


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
                    if (snapshots.docs.length < pagesize) {

                        jQuery("#data-table_paginate").hide();
                    } else {

                        jQuery("#data-table_paginate").show();
                    }
                }
            });
        }


    }


    async function payoutDriverfunction(driver) {
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

</script>


@endsection
