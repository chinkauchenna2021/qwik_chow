@extends('layouts.app')

@section('content')

<div class="page-wrapper">

    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor restaurantTitle">{{trans('lang.book_table')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">

            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item active">{{trans('lang.book_table')}}</li>
            </ol>

        </div>

    </div>


    <div class="container-fluid">

        <div class="row">

            <div class="col-12">

                <div class="menu-tab">
                    <ul>
                        <li>
                            <a href="{{route('restaurants.view',$id)}}">{{trans('lang.tab_basic')}}</a>
                        </li>
                        <li>
                            <a href="{{route('restaurants.foods',$id)}}">{{trans('lang.tab_foods')}}</a>
                        </li>
                        <li>
                            <a href="{{route('restaurants.orders',$id)}}">{{trans('lang.tab_orders')}}</a>
                        </li>
                        <li>
                            <a href="{{route('restaurants.coupons',$id)}}">{{trans('lang.tab_promos')}}</a>
                        <li>
                            <a href="{{route('restaurants.payout',$id)}}">{{trans('lang.tab_payouts')}}</a>
                        </li>
                        <li class="active">
                            <a href="{{route('restaurants.booktable',$id)}}">{{trans('lang.dine_in_future')}}</a>
                        </li>
                    </ul>

                </div>

                <div class="card">

                    <div class="card-header">
                        <ul class="nav nav-tabs align-items-end card-header-tabs w-100">
                            <li class="nav-item">
                                <a class="nav-link active" href="{{ url()->current() }}"><i class="fa fa-list mr-2"></i>{{trans('lang.book_table_table')}}</a>
                            </li>
                        </ul>
                    </div>

                    <div class="card-body">

                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">Processing...
                        </div>


                        <div class="table-responsive m-t-10">


                            <table id="bookTable"
                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                   cellspacing="0" width="100%">

                                <thead>

                                <tr>
                                    <th>{{trans('lang.date')}}</th>
                                    <th>{{trans('lang.guestNumber')}}</th>
                                    <th>{{trans('lang.guestName')}}</th>
                                    <th>{{trans('lang.guestPhone')}}</th>
                                    <th>{{trans('lang.status')}}</th>
                                    <th>{{trans('lang.actions')}}</th>
                                </tr>

                                </thead>

                                <tbody id="append_list1">


                                </tbody>

                            </table>
                            <!--<div id="data-table_paginate" style="display:none">
                                <nav aria-label="Page navigation example">
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
                                </nav>
                            </div>-->
                        </div>
                    </div>
                </div>

            </div>

        </div>

    </div>

</div>

@endsection

@section('scripts')

<script type="text/javascript">

    var database = firebase.firestore();
    var offest = 1;
    var pagesize = 10;
    var end = null;
    var endarray = [];
    var start = null;
    var user_number = [];
    var vendorUserId = "<?php echo $id; ?>";
    var vendorId;
    var ref;
    var append_list = '';
    var placeholderImage = '';
    var dineInOrderAcceptedSubject = '';
    var dineInOrderAcceptedMsg = '';
    var dineInOrderRejectedSubject = '';
    var dineInOrderRejectedMsg = '';


    database.collection('dynamic_notification').where('type', 'in', ['dinein_accepted', 'dinein_canceled']).get().then(async function (snapshot) {
        if (snapshot.docs.length > 0) {
            snapshot.docs.map(async (listval) => {
                val = listval.data();
                if (val.type == "dinein_accepted") {
                    dineInOrderAcceptedSubject = val.subject;
                    dineInOrderAcceptedMsg = val.message;
                } else if (val.type == "dinein_canceled") {
                    var dineInOrderRejectedSubject = val.subject;
                    var dineInOrderRejectedMsg = val.message;

                }

            });
        }
    });


    ref = database.collection('booked_table').orderBy('createdAt', 'desc').where('vendorID', "==", vendorUserId);
    const getStoreName = getStoreNameFunction('<?php echo $id; ?>');

    $(document).ready(function () {

        $(document.body).on('click', '.redirecttopage', function () {
            var url = $(this).attr('data-url');
            window.location.href = url;
        });
        var inx = parseInt(offest) * parseInt(pagesize);
        jQuery("#data-table_processing").show();
        append_list = document.getElementById('append_list1');
        append_list.innerHTML = '';

        var placeholder = database.collection('settings').doc('placeHolderImage');
        placeholder.get().then(async function (snapshotsimage) {
            var placeholderImageData = snapshotsimage.data();
            placeholderImage = placeholderImageData.image;
        })

        ref.get().then(async function (snapshots) {
            var html = '';
            html = await buildHTML(snapshots);
            if (html != '') {
                append_list.innerHTML = html;
                start = snapshots.docs[snapshots.docs.length - 1];
                endarray.push(snapshots.docs[0]);
            }


            $('#bookTable').DataTable({
                order: [],
                columnDefs: [
                    {
                        targets: 0,
                        type: 'date',
                        render: function (data) {

                            return data;
                        }
                    },
                    {orderable: false, targets: [5]},

                ],
                order: [['0', 'desc']],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                responsive: true
            });
            if (snapshots.docs.length < pagesize) {
                jQuery("#data-table_paginate").hide();
            } else {
                jQuery("#data-table_paginate").show();
            }

            jQuery("#data-table_processing").hide();
        });
    });

    async function buildHTML(snapshots) {
        var html = '';
        await Promise.all(snapshots.docs.map(async (listval) => {
            var datas = listval.data();
            var getData = await getListData(datas);
            html += getData;

        }));
        return html;
    }

    function getListData(val) {
        var html = '';
        html = html + '<tr>';
        newdate = '';

        var id = val.id;
        var route1 = '{{route("booktable.edit",":id")}}?id=<?php echo $id; ?>';
        route1 = route1.replace(':id', id);

        var date = '';
        var time = '';
        if (val.hasOwnProperty("date")) {

            try {
                date = val.date.toDate().toDateString();
                time = val.date.toDate().toLocaleTimeString('en-US');
            } catch (err) {

            }
            html = html + '<td class="dt-time">' + date + ' ' + time + '</td>';
        } else {
            html = html + '<td></td>';
        }

        html = html + '<td>' + val.totalGuest + '</td>';
        html = html + '<td>' + val.guestFirstName + ' ' + val.guestLastName + '</td>';
        html = html + '<td>' + val.guestPhone + '</td>';
        var statustext = "";
        if (val.status == "Order Rejected") {
            statustext = '<span class="badge badge-danger py-2 px-3">Request Rejected</span>';

        } else if (val.status == "Order Placed") {
            statustext = '<span class="badge badge-warning py-2 px-3">Requested</span>';

        } else if (val.status == "Order Accepted") {
            statustext = '<span class="badge badge-success py-2 px-3">Request Accepted</span>';
        }
        html = html + '<td>' + statustext + '</td>';


        html = html + '<td class="action-btn"><a id="' + val.id + '" name="book-table-check" data-name="' + val.vendor.title + '" data-auth="' + val.author.id + '" href="javascript:void(0)"><i class="fa fa-check" ></i></a><a id="' + val.id + '" name="book-table-dismiss" data-auth="' + val.author.id + '" data-name="' + val.vendor.title + '" href="javascript:void(0)"><i class="fa fa-close" ></i></a><a href="' + route1 + '"><i class="fa fa-edit"></i></a><a id="' + val.id + '" name="book-table-delete" class="do_not_delete" href="javascript:void(0)"><i class="fa fa-trash"></i></a></td>';


        html = html + '</tr>';

        return html;
    }


    async function getStoreNameFunction(vendorId) {
        var vendorName = '';
        await database.collection('vendors').where('id', '==', vendorId).get().then(async function (snapshots) {
            if (!snapshots.empty) {
                var vendorData = snapshots.docs[0].data();

                vendorName = vendorData.title;
                $('.restaurantTitle').html('{{trans("lang.book_table")}} - ' + vendorName);

                if (vendorData.dine_in_active == true) {
                    $(".dine_in_future").show();
                }
            }
        });

        return vendorName;

    }

    function prev() {

        if (endarray.length == 1) {
            return false;
        }
        end = endarray[endarray.length - 2];
        console.log(endarray);

        if (end != undefined || end != null) {

            jQuery("#data-table_processing").show();

            if (jQuery("#selected_search").val() == 'name' && jQuery("#search").val().trim() != '') {
                listener = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();
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
                    console.log(start);
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
            // listener = ref.startAfter(start).limit(pagesize).get();

            if (jQuery("#selected_search").val() == 'name' && jQuery("#search").val().trim() != '') {

                listener = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();
            } else {
                listener = ref.startAfter(start).limit(pagesize).get();
            }
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
        }
    }

    function searchclear() {
        jQuery("#search").val('');
        searchtext();
    }

    function searchtext() {

        var offest = 1;

        jQuery("#data-table_processing").show();

        append_list.innerHTML = '';

        if (jQuery("#selected_search").val() == 'name' && jQuery("#search").val().trim() != '') {

            wherequery = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

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
                if (snapshots.docs.length < pagesize) {

                    jQuery("#data-table_paginate").hide();
                } else {

                    jQuery("#data-table_paginate").show();
                }
            }
        });

    }

    $(document).on("click", "a[name='book-table-delete']", function (e) {
        var id = this.id;
        database.collection('booked_table').doc(id).delete().then(function (result) {
            window.location.href = '{{ url()->current() }}';
        });

    });


    $(document).on("click", "a[name='book-table-check']", function (e) {
        var id = this.id;
        var fullname = $(this).attr('data-name');
        var auth = $(this).attr('data-auth');
        database.collection('booked_table').doc(id).update({'status': 'Order Accepted'}).then(function (result) {

            database.collection('users').where('id', '==', auth).get().then(function (snapshots) {

                if (snapshots.docs.length) {
                    snapshots.forEach((doc) => {
                        user = doc.data();
                        if (user.fcmToken) {
                            $.ajax({
                                method: 'POST',
                                url: '<?php echo route('sendnotification'); ?>',
                                data: {
                                    'fcm': user.fcmToken,
                                    'type': 'booktable_request_accepted',
                                    'authorName': fullname,
                                    '_token': '<?php echo csrf_token() ?>',
                                    'subject': dineInOrderAcceptedSubject,
                                    'message': dineInOrderAcceptedMsg
                                }
                            }).done(function (data) {
                                window.location.href = '{{ url()->current() }}';
                            }).fail(function (xhr, textStatus, errorThrown) {
                                window.location.href = '{{ url()->current() }}';
                            });
                        } else {
                            window.location.href = '{{ url()->current() }}';
                        }
                    });
                } else {
                    //window.location.href = '{{ url()->current() }}';
                }
            });

        });

    });

    $(document).on("click", "a[name='book-table-dismiss']", function (e) {
        var id = this.id;
        var fullname = $(this).attr('data-name');
        var auth = $(this).attr('data-auth');
        database.collection('booked_table').doc(id).update({'status': 'Order Rejected'}).then(function (result) {

            database.collection('users').where('id', '==', auth).get().then(function (snapshots) {
                if (snapshots.length) {
                    snapshots.forEach((doc) => {
                        if (doc.fcmToken) {
                            $.ajax({
                                method: 'POST',
                                url: '<?php echo route('sendnotification'); ?>',
                                data: {
                                    'fcm': doc.fcmToken,
                                    'type': 'booktable_request_reject',
                                    'authorName': fullname,
                                    '_token': '<?php echo csrf_token() ?>',
                                    'subject': dineInOrderRejectedSubject,
                                    'message': dineInOrderRejectedMsg
                                }
                            }).done(function (data) {
                                window.location.href = '{{ url()->current() }}';
                            }).fail(function (xhr, textStatus, errorThrown) {
                                window.location.href = '{{ url()->current() }}';
                            });
                        } else {
                            window.location.href = '{{ url()->current() }}';
                        }
                    });
                } else {
                    window.location.href = '{{ url()->current() }}';
                }
            });


        });

    });

</script>


@endsection
