@extends('layouts.app')

@section('content')
<div class="page-wrapper">
    <div class="row page-titles">
        <div class="col-md-5 align-self-center">
             @if($id=='')
                <h3 class="text-themecolor">{{trans('lang.create_notification')}}</h3>
                @else
                <h3 class="text-themecolor">{{trans('lang.edit_notification')}}</h3>
                 @endif
            
        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item"><a href="{{ url('dynamic-notification') }}">{{trans('lang.dynamic_notification')}}</a></li>
                
                @if($id=='')
                <li class="breadcrumb-item active">{{trans('lang.create_notification')}}</li>
                @else
                <li class="breadcrumb-item active">{{trans('lang.edit_notification')}}</li>
                @endif
                
                
            </ol>
        </div>

    </div>
    <div>

        <div class="card-body">

            <div id="data-table_processing" class="dataTables_processing panel panel-default" style="display: none;">
                {{trans('lang.processing')}}
            </div>

            <div class="error_top" style="display:none"></div>

            <div class="success_top" style="display:none"></div>

            <div class="row restaurant_payout_create">

                <div class="restaurant_payout_create-inner">

                    <fieldset>
                        <legend>{{trans('lang.notification')}}</legend>

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.type')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control" id="type" readonly>
                            </div>
                        </div>
                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.subject')}}</label>
                            <div class="col-7">
                                <input type="text" class="form-control" id="subject">
                            </div>
                        </div>

                        

                        <div class="form-group row width-100">
                            <label class="col-3 control-label">{{trans('lang.message')}}</label>
                            <div class="col-7">
                                <textarea class="form-control" id="message"></textarea>
                            </div>
                        </div>

                    </fieldset>
                </div>

            </div>

        </div>
        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary send_message"><i class="fa fa-save"></i> {{
                trans('lang.save')}}
            </button>
            <a href="{{url('/dynamic-notification')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{
                trans('lang.cancel')}}</a>
        </div>

    </div>

    @endsection

    @section('scripts')

    <script>

        var requestId = "<?php echo $id; ?>";
        var database = firebase.firestore();
        var createdAt = firebase.firestore.FieldValue.serverTimestamp();
        var id = (requestId == '') ? database.collection("tmp").doc().id : requestId;

        var pagesize = 20;
        var start = '';
        $(document).ready(function () {
            if (requestId != '') {
                var ref = database.collection('dynamic_notification').where('id','==',id);
                jQuery("#data-table_processing").show();
                ref.get().then(async function (snapshots) {
                    if (snapshots.docs.length) {
                        var np = snapshots.docs[0].data();
                        $("#message").val(np.message);
                        $("#subject").val(np.subject);
                          
                        
            if(np.type=="restaurant_rejected"){
                type="{{trans('lang.order_rejected_by_restaurant')}}";
               
            }
            else if(np.type=="restaurant_accepted"){
                type="{{trans('lang.order_accepted_by_restaurant')}}";
            }
            else if(np.type=="takeaway_completed"){
                type="{{trans('lang.takeaway_order_completed')}}";
            }
            else if(np.type=="driver_completed"){
                type="{{trans('lang.driver_completed_order')}}";

            }
            else if(np.type=="driver_accepted"){
                type="{{trans('lang.driver_accepted_order')}}";
            }
            else if(np.type=="dinein_canceled"){
                type="{{trans('lang.dine_order_book_canceled')}}";
            }
            else if(np.type=="dinein_accepted"){
                type="{{trans('lang.dine_order_book_accepted')}}";
            }
            else if(np.type=="order_placed"){
                type="{{trans('lang.new_order_place')}}";
            }
            else if(np.type=="dinein_placed"){
                type="{{trans('lang.new_dine_booking')}}";

            }else if(np.type=="schedule_order"){
                type="{{trans('lang.shedule_order')}}";
            }
            else if(np.type=="payment_received"){
                type="{{trans('lang.pament_received')}}";
            }  
            $('#type').val(type);   

        }
                jQuery("#data-table_processing").hide();

                });
            }
        });

        $(".send_message").click(async function () {

            $(".success_top").hide();
            $(".error_top").hide();
            var message = $("#message").val();
            var subject = $("#subject").val();
            var type=$('#type').val();

            if (subject == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.please_enter_subject')}}</p>");
                window.scrollTo(0, 0);
                return false;
            } else if (message == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.please_enter_message')}}</p>");
                window.scrollTo(0, 0);
                return false;
            } else {
                jQuery("#data-table_processing").show();
                requestId == '' ? (database.collection('dynamic_notification').doc(id).set({
                    'id': id,
                    'subject': subject,
                    'message': message,
                    'type':type,
                    'createdAt': createdAt

                }).then(function (result) {
                    jQuery("#data-table_processing").hide();
                    $(".success_top").show();
                    $(".success_top").html("");
                    $(".success_top").append("<p>{{trans('lang.notification_created_success')}}</p>");
                    window.scrollTo(0, 0);
                    window.location.href = '{{ route("dynamic-notification.index")}}';
                }).catch(function (error) {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + error + "</p>");
                })) :
                    (database.collection('dynamic_notification').doc(id).update({

                        'subject': subject,
                        'message': message,
                        

                    }).then(function (result) {
                        jQuery("#data-table_processing").hide();
                        $(".success_top").show();
                        $(".success_top").html("");
                        $(".success_top").append("<p>{{trans('lang.notification_updated_success')}}</p>");
                        window.scrollTo(0, 0);

                        window.location.href = '{{ route("dynamic-notification.index")}}';
                    }).catch(function (error) {
                        $(".error_top").show();
                        $(".error_top").html("");
                        $(".error_top").append("<p>" + error + "</p>");
                    }));


            }




        });



    </script>

    @endsection