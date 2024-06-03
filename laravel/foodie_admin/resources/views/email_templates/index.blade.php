@extends('layouts.app')

@section('content')

    <div class="page-wrapper">


        <div class="row page-titles">

            <div class="col-md-5 align-self-center">

                <h3 class="text-themecolor">{{trans('lang.email_templates')}}</h3>

            </div>

            <div class="col-md-7 align-self-center">

                <ol class="breadcrumb">

                    <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>

                    <li class="breadcrumb-item">{{trans('lang.email_templates')}}</li>

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
                                                class="fa fa-list mr-2"></i>{{trans('lang.email_templates_table')}}</a>
                                </li>
                               {{-- <li class="nav-item">
                                    <a class="nav-link" href="{!! url('email-templates/save') !!}"><i
                                                class="fa fa-plus mr-2"></i>{{trans('lang.create_email_templates')}}</a>
                                </li>--}}

                            </ul>
                        </div>
                        <div class="card-body">

                            <div class="table-responsive m-t-10">


                                <table id="emailTemplatesTable"
                                       class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                       cellspacing="0" width="100%">

                                    <thead>

                                    <tr>

                                        <th>{{trans('lang.type')}}</th>
                                        <th>{{trans('lang.subject')}}</th>

                                        <th>{{trans('lang.actions')}}</th>

                                    </tr>

                                    </thead>

                                    <tbody id="emailTemplatesTbody">


                                    </tbody>

                                </table>
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
        var refData = database.collection('email_templates').orderBy('createdAt', 'desc');
        var append_list = '';

        $(document).ready(function () {

            jQuery("#data-table_processing").show();

            append_list = document.getElementById('emailTemplatesTbody');
            append_list.innerHTML = '';
            refData.get().then(async function (snapshots) {
                var html = '';
                html = await buildHTML(snapshots);
                jQuery("#data-table_processing").hide();
                if (html != '') {
                    append_list.innerHTML = html;
                    $('[data-toggle="tooltip"]').tooltip();
                }

                $('#emailTemplatesTable').DataTable({
                    order: [],
                    columnDefs: [
                        {orderable: false, targets: [2]},
                    ],
                    "language": {
                        "zeroRecords": "{{trans("lang.no_record_found")}}",
                        "emptyTable": "{{trans("lang.no_record_found")}}"
                    },
                    responsive: true
                });
            });

        });

        $("#is_active").click(function () {
            $("#emailTemplatesTable .is_open").prop('checked', $(this).prop('checked'));
        });

        $("#deleteAll").click(function () {
            if ($('#emailTemplatesTable .is_open:checked').length) {
                if (confirm("{{trans('lang.selected_delete_alert')}}")) {
                    jQuery("#data-table_processing").show();
                    $('#emailTemplatesTable .is_open:checked').each(function () {
                        var dataId = $(this).attr('dataId');

                        database.collection('email_templates').doc(dataId).delete().then(function () {

                            window.location.reload();
                        });

                    });

                }
            } else {
                alert("{{trans('lang.select_delete_alert')}}");
            }
        });


        function buildHTML(snapshots) {

            var html = '';
            var number = [];
            var count = 0;
            snapshots.docs.forEach(async (listval) => {
                var listval = listval.data();

                var data = listval;
                data.id = listval.id;
                html = html + '<tr>';
                newdate = '';
                var id = data.id;
                var route1 = '{{route("email-templates.save",":id")}}';
                route1 = route1.replace(":id", id);

                var type = '';

                if (data.type == "new_order_placed") {
                    type = "{{trans('lang.new_order_placed')}}";

                } else if (data.type == "new_vendor_signup") {
                    type = "{{trans('lang.new_vendor_signup')}}";
                } else if (data.type == "payout_request") {
                    type = "{{trans('lang.payout_request')}}";
                } else if (data.type == "payout_request_status") {
                    type = "{{trans('lang.payout_request_status')}}";

                } else if (data.type == "wallet_topup") {
                    type = "{{trans('lang.wallet_topup')}}";
                }

                html = html + '<td>' + type + '</td>';
                html = html + '<td>' + data.subject + '</td>';

                html = html + '<td class="action-btn">' +
                    //'<i class="text-dark fs-12 fa-solid fa fa-info" data-toggle="tooltip" title="' + type + '" aria-describedby="tippy-3"></i>' +
                    '<a href="' + route1 + '"><i class="fa fa-edit"></i></a></td>';

                html = html + '</tr>';
                count = count + 1;
            });
            return html;
        }

        $(document).on("click", "a[name='notifications-delete']", function (e) {
            var id = this.id;
            database.collection('email_templates').doc(id).delete().then(function () {
                window.location.reload();
            });
        });
    </script>


@endsection