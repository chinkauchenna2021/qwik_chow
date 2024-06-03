@extends('layouts.app')


@section('content')

<div class="page-wrapper">


    <div class="row page-titles">


        <div class="col-md-5 align-self-center">


            <h3 class="text-themecolor">{{trans('lang.menu_items')}}</h3>


        </div>


        <div class="col-md-7 align-self-center">


            <ol class="breadcrumb">


                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>


                <li class="breadcrumb-item">{{trans('lang.menu_items')}}</li>


                <li class="breadcrumb-item active">{{trans('lang.menu_items_table')}}</li>


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
                                            class="fa fa-list mr-2"></i>{{trans('lang.menu_items_table')}}</a>

                            </li>

                            <li class="nav-item">

                                <a class="nav-link" href="{!! route('setting.banners.create') !!}"><i
                                            class="fa fa-plus mr-2"></i>{{trans('lang.menu_items_create')}}</a>

                            </li>


                        </ul>

                    </div>

                    <div class="card-body">

                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">{{trans('lang.processing')}}
                        </div>
                        <!--<div id="users-table_filter" class="pull-right">
                            <div class="row">

                                <div class="col-sm-9">
                                    <label>{{ trans('lang.search_by')}}
                                        <select name="selected_search" id="selected_search"
                                                class="form-control input-sm">
                                            <option value="title">{{ trans('lang.title')}}</option>
                                        </select>
                                        <div class="form-group">
                                            <input type="search" id="search" class="search form-control"
                                                   placeholder="Search" aria-controls="users-table">
                                    </label>&nbsp;<button onclick="searchtext();" class="btn btn-warning btn-flat">
                                        Search
                                    </button>&nbsp;<button onclick="searchclear();" class="btn btn-warning btn-flat">
                                        Clear
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>-->

                        <div class="table-responsive m-t-10">

                            <table id="bannerItemsTable"
                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                   cellspacing="0" width="100%">


                                <thead>


                                <tr>
                                    <th class="delete-all"><input type="checkbox" id="is_active"><label
                                                class="col-3 control-label" for="is_active">
                                            <a id="deleteAll" class="do_not_delete" href="javascript:void(0)">
                                                <i class="fa fa-trash"></i> {{trans('lang.all')}}</a></label></th>

                                    <th>{{trans('lang.photo')}}</th>
                                    <th>{{trans('lang.title')}}</th>
                                    <th>{{trans('lang.banner_position')}}</th>
                                    <th>{{trans('lang.publish')}}</th>


                                    <th>{{trans('lang.actions')}}</th>


                                </tr>


                                </thead>


                                <tbody id="append_vendors">

                                </tbody>


                            </table>

                            <!--<div class="data-table_paginate">

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

    var refData = database.collection('menu_items').orderBy('title');

    var append_list = '';

    var placeholderImage = '';

    var placeholder = database.collection('settings').doc('placeHolderImage');


    placeholder.get().then(async function (snapshotsimage) {

        var placeholderImageData = snapshotsimage.data();

        placeholderImage = placeholderImageData.image;

    })


    $(document).ready(function () {


        var inx = parseInt(offest) * parseInt(pagesize);

        jQuery("#data-table_processing").show();


        append_list = document.getElementById('append_vendors');

        append_list.innerHTML = '';

        refData.get().then(async function (snapshots) {

            html = '';

            html = await buildHTML(snapshots);

            jQuery("#data-table_processing").hide();

            if (html != '') {

                append_list.innerHTML = html;

                start = snapshots.docs[snapshots.docs.length - 1];

                endarray.push(snapshots.docs[0]);

                if (snapshots.docs.length < pagesize) {

                    jQuery("#data-table_paginate").hide();

                }

            }


            $('#bannerItemsTable').DataTable({
                order: [['2', 'asc']],
                columnDefs: [

                    {orderable: false, targets: [0, 1, 4, 5]},
                ],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                responsive: true
            });

        });


    })


    function buildHTML(snapshots) {


        if (snapshots.docs.length < pagesize) {

            jQuery("#data-table_paginate").hide();

        }

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

            var route1 = '{{route("setting.banners.edit",":id")}}';

            route1 = route1.replace(':id', id);
            html = html + '<td class="delete-all"><input type="checkbox" id="is_open_' + id + '" class="is_open" dataId="' + id + '" style="width:30px;"><label class="col-3 control-label"\n' +
                'for="is_open_' + id + '" ></label></td>';
            if (val.photo != '') {

                html = html + '<td><img alt="" width="100%" style="width:70px;height:70px;" src="' + val.photo + '" alt="image"></td>';

            } else {

                html = html + '<td><img alt="" width="100%" style="width:70px;height:70px;" src="' + placeholderImage + '" alt="image"></td>';

            }

            html = html + '<td><a href="' + route1 + '">' + val.title + '</a></td>';
            html = html + '<td>' + val.position + '</td>';

            // if(val.is_publish){

            //     html=html+'<td><span class="badge badge-success">Yes</span></td>';

            // }else{

            //     html=html+'<td><span class="badge badge-danger">No</span></td>';

            // }

            if (val.is_publish) {
                html = html + '<td><label class="switch"><input type="checkbox" checked id="' + val.id + '" name="publish"><span class="slider round"></span></label></td>';
            } else {
                html = html + '<td><label class="switch"><input type="checkbox" id="' + val.id + '" name="publish"><span class="slider round"></span></label></td>';
            }

            html = html + '<td class="vendor-action-btn"><a href="' + route1 + '"><i class="fa fa-edit"></i></a><a id="' + val.id + '" name="vendor-delete" class="do_not_delete" href="javascript:void(0)"><i class="fa fa-trash"></i></a></td>';


            html = html + '</tr>';

            count = count + 1;

        });

        return html;

    }

    /* toggal publish action code start*/
    $(document).on("click", "input[name='publish']", function (e) {
        var ischeck = $(this).is(':checked');
        var id = this.id;
        if (ischeck) {
            database.collection('menu_items').doc(id).update({'is_publish': true}).then(function (result) {

            });
        } else {
            database.collection('menu_items').doc(id).update({'is_publish': false}).then(function (result) {

            });
        }

    });

    /*toggal publish action code end*/

    $("#is_active").click(function () {
        $("#example24 .is_open").prop('checked', $(this).prop('checked'));

    });

    $("#deleteAll").click(function () {
        if ($('#example24 .is_open:checked').length) {
            if (confirm('Are You Sure want to Delete Selected Data ?')) {
                jQuery("#data-table_processing").show();
                $('#example24 .is_open:checked').each(function () {
                    var dataId = $(this).attr('dataId');

                    database.collection('menu_items').doc(dataId).delete().then(function () {
                        window.location.reload();

                    });

                });

            }
        } else {
            alert('Please Select Any One Record .');
        }
    });

    async function next() {

        if (start != undefined || start != null) {

            jQuery("#data-table_processing").hide();


            if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {

                console.log(jQuery("#selected_search").val());


                listener = refData.orderBy('title').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();

            } else {

                listener = refData.startAfter(start).limit(pagesize).get();

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

            if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {


                listener = refData.orderBy('title').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();

            } else {

                listener = refData.startAt(end).limit(pagesize).get();

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

    }


    function searchtext() {


        jQuery("#data-table_processing").show();


        append_list.innerHTML = '';


        if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {

            console.log(jQuery("#search").val());

            wherequery = refData.orderBy('title').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();

        } else {

            wherequery = refData.limit(pagesize).get();

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

    $(document).on("click", "a[name='vendor-delete']", function (e) {
        var id = this.id;
        database.collection('menu_items').doc(id).delete().then(function () {
            window.location.reload();
        });
    });


</script>

@endsection
