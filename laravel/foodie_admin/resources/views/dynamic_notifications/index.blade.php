@extends('layouts.app')

@section('content')

<div class="page-wrapper">


    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor">{{trans('lang.dynamic_notification')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">

            <ol class="breadcrumb">

                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>

                <li class="breadcrumb-item">{{trans('lang.dynamic_notification')}}</li>

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
                                            class="fa fa-list mr-2"></i>{{trans('lang.notificaions_table')}}</a>
                            </li>
                            {{--
                            <li class="nav-item">
                                <a class="nav-link" href="{!! url('dynamic-notification/save') !!}"><i
                                            class="fa fa-plus mr-2"></i>{{trans('lang.create_notificaion')}}</a>
                            </li>
                            --}}

                        </ul>
                    </div>
                    <div class="card-body">

                        <!--<div id="users-table_filter" class="pull-right"><label>{{trans('lang.search_by')}}
                                <select name="selected_search" id="selected_search" class="form-control input-sm">
                                    <option value="subject">{{trans('lang.subject')}}</option>
                                </select>
                                <div class="form-group">
                                    <input type="search" id="search" class="search form-control" placeholder="Search">
                            </label>&nbsp;<button onclick="searchtext();"
                                                  class="btn btn-warning btn-flat">{{trans('lang.search')}}
                            </button>&nbsp;<button
                                    onclick="searchclear();"
                                    class="btn btn-warning btn-flat">{{trans('lang.clear')}}
                            </button>
                        </div>
                    </div>-->


                    <div class="table-responsive m-t-10">


                        <table id="notificationTable"
                               class="display nowrap table table-hover table-striped table-bordered table table-striped"
                               cellspacing="0" width="100%">

                            <thead>

                            <tr>

                                <th>{{trans('lang.type')}}</th>
                                <th>{{trans('lang.subject')}}</th>

                                <th>{{trans('lang.message')}}</th>

                                <th>{{trans('lang.date_created')}}</th>

                                <th>{{trans('lang.actions')}}</th>

                            </tr>

                            </thead>

                            <tbody id="append_restaurants">


                            </tbody>

                        </table>
                        {{--
                        <div class="data-table_paginate">
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
                        </div>
                        --}}

                    </div>

                </div>

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
    var refData = database.collection('dynamic_notification');
    var ref = refData.orderBy('createdAt', 'desc');
    var append_list = '';


    $(document).ready(function () {


        var inx = parseInt(offest) * parseInt(pagesize);
        jQuery("#data-table_processing").show();

        append_list = document.getElementById('append_restaurants');
        append_list.innerHTML = '';
        ref.get().then(async function (snapshots) {
            html = '';
            html = await buildHTML(snapshots);
            jQuery("#data-table_processing").hide();
            if (html != '') {
                append_list.innerHTML = html;
                $('[data-toggle="tooltip"]').tooltip();
                //start = snapshots.docs[snapshots.docs.length - 1];
                //endarray.push(snapshots.docs[0]);
                /*if (snapshots.docs.length < pagesize) {
                    jQuery("#data-table_paginate").hide();
                }*/

            }

            $('#notificationTable').DataTable({
                order: [],
                columnDefs: [
                    {
                        targets: 3,
                        type: 'date',
                        render: function (data) {

                            return data;
                        }
                    },
                    {orderable: false, targets: [4]},
                ],
                order: [['3', 'desc']],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                responsive: true
            });
        });

    })
    $("#is_active").click(function () {
        $("#notificationTable .is_open").prop('checked', $(this).prop('checked'));
    });

    $("#deleteAll").click(function () {
        if ($('#notificationTable .is_open:checked').length) {
            if (confirm("{{trans('lang.selected_delete_alert')}}")) {
                jQuery("#data-table_processing").show();
                $('#notificationTable .is_open:checked').each(function () {
                    var dataId = $(this).attr('dataId');

                    database.collection('dynamic_notification').doc(dataId).delete().then(function () {

                        window.location.reload();
                    });

                });

            }
        } else {
            alert("{{trans('lang.select_delete_alert')}}");
        }
    });


    function buildHTML(snapshots) {

        /*if (snapshots.docs.length < pagesize) {
            jQuery("#data-table_paginate").hide();
        }*/
        var html = '';
        var number = [];
        var count = 0;
        snapshots.docs.forEach(async (listval) => {
            var listval = listval.data();

            var val = listval;
            val.id = listval.id;
            html = html + '<tr>';
            newdate = '';
            var id = val.id;
            route1 = '{{route("dynamic-notification.save",":id")}}'
            route1 = route1.replace(":id", id);

            if (val.type == "restaurant_rejected") {

                type = "{{trans('lang.order_rejected_by_restaurant')}}";
                title = "{{trans('lang.order_reject_notification')}}";
            } else if (val.type == "restaurant_accepted") {
                type = "{{trans('lang.order_accepted_by_restaurant')}}";
                title = "{{trans('lang.order_accept_notification')}}";
            } else if (val.type == "takeaway_completed") {
                type = "{{trans('lang.takeaway_order_completed')}}";
                title = "{{trans('lang.takeaway_order_complete_notification')}}";
            } else if (val.type == "driver_completed") {
                type = "{{trans('lang.driver_completed_order')}}";
                title = "{{trans('lang.order_complete_notification')}}";

            } else if (val.type == "driver_accepted") {
                type = "{{trans('lang.driver_accepted_order')}}";
                title = "{{trans('lang.driver_accept_order_notification')}}";
            } else if (val.type == "dinein_canceled") {
                type = "{{trans('lang.dine_order_book_canceled')}}";
                title = "{{trans('lang.dinein_cancel_notification')}}";
            } else if (val.type == "dinein_accepted") {
                type = "{{trans('lang.dine_order_book_accepted')}}";
                title = "{{trans('lang.dinein_accept_notification')}}";
            } else if (val.type == "order_placed") {
                type = "{{trans('lang.new_order_place')}}";
                title = "{{trans('lang.order_placed_notification')}}";
            } else if (val.type == "dinein_placed") {
                type = "{{trans('lang.new_dine_booking')}}";
                title = "{{trans('lang.dinein_order_place_notification')}}";

            } else if (val.type == "schedule_order") {
                type = "{{trans('lang.shedule_order')}}";
                title = "{{trans('lang.schedule_order_notification')}}";
            } else if (val.type == "payment_received") {
                type = "{{trans('lang.pament_received')}}";
                title = "{{trans('lang.payment_receive_notification')}}";
            }

            html = html + '<td>' + type + '</td>';
            html = html + '<td>' + val.subject + '</td>';

            html = html + '<td>' + val.message + '</td>';

            var date = '';
            var time = '';
            if (val.hasOwnProperty("createdAt")) {

                try {
                    date = val.createdAt.toDate().toDateString();
                    time = val.createdAt.toDate().toLocaleTimeString('en-US');
                } catch (err) {

                }
                html = html + '<td class="dt-time">' + date + ' ' + time + '</td>';
            } else {
                html = html + '<td></td>';
            }

            html = html + '<td class="action-btn"><i class="text-dark fs-12 fa-solid fa fa-info" data-toggle="tooltip" title="' + title + '" aria-describedby="tippy-3"></i><a href="' + route1 + '"><i class="fa fa-edit"></i></a></td>';

            html = html + '</tr>';
            count = count + 1;
        });
        return html;
    }


    /* async function next() {
         if (start != undefined || start != null) {
             jQuery("#data-table_processing").hide();

             if (jQuery("#selected_search").val() == 'subject' && jQuery("#search").val().trim() != '') {
                 console.log(jQuery("#selected_search").val());

                 listener = refData.orderBy('subject').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();
             } else {
                 listener = ref.startAfter(start).limit(pagesize).get();
             }
             listener.then(async (snapshots) => {

                 html = '';
                 html = await buildHTML(snapshots);
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

     async function prev() {
         if (endarray.length == 1) {
             return false;
         }
         end = endarray[endarray.length - 2];

         if (end != undefined || end != null) {
             jQuery("#data-table_processing").show();
             if (jQuery("#selected_search").val() == 'subject' && jQuery("#search").val().trim() != '') {

                 listener = refData.orderBy('subject').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();
             } else {
                 listener = ref.startAt(end).limit(pagesize).get();
             }

             listener.then(async (snapshots) => {
                 html = '';
                 html = await buildHTML(snapshots);
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
     }*/


    function searchtext() {

        jQuery("#data-table_processing").show();

        append_list.innerHTML = '';

        if (jQuery("#selected_search").val() == 'subject' && jQuery("#search").val().trim() != '') {
            console.log(jQuery("#search").val());
            wherequery = refData.orderBy('subject').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();
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

    function searchclear() {
        jQuery("#search").val('');
        searchtext();
    }

    $(document).on("click", "a[name='notifications-delete']", function (e) {
        var id = this.id;
        database.collection('dynamic_notification').doc(id).delete().then(function () {
            window.location.reload();
        });
    });
</script>


@endsection