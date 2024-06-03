@extends('layouts.app')

@section('content')
	<div class="page-wrapper">
    <div class="row page-titles">

        <div class="col-md-5 align-self-center">
            <h3 class="text-themecolor">{{ trans('lang.dine_in_future_setting')}}</h3>
        </div>
        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item active">{{ trans('lang.dine_in_future_setting')}}</li>
            </ol>
        </div>
    </div>

        <div class="card-body">
      	  <div id="data-table_processing" class="dataTables_processing panel panel-default" style="display: none;">Processing...</div>
          <div class="row restaurant_payout_create">
            <div class="restaurant_payout_create-inner"> 
              <fieldset>
                <legend>{{trans('lang.dine_in_future_setting')}}</legend>
                    
                    <div class="form-check width-100">
                      <input type="checkbox" class="form-check-inline" onclick="ShowHideDiv()" id="enable_dine_in_for_restaurant">
                        <label class="col-5 control-label" for="enable_dine_in_for_restaurant">{{ trans('lang.enable_dine_in_future')}}</label>
                    </div>
                    <div class="form-check width-100">
                      <input type="checkbox" class="form-check-inline" onclick="ShowHideDiv()" id="dine_in_customers">
                        <label class="col-5 control-label" for="dine_in_customers">{{ trans('lang.dine_in_customers')}}</label>
                    </div>
              </fieldset>
            </div>
          </div>

          <div class="form-group col-12 text-center">
            <button type="button" class="btn btn-primary save_booking_table_btn" ><i class="fa fa-save"></i> {{trans('lang.save')}}</button>
            <a href="{{url('/dashboard')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
          </div>
        </div>    


 @endsection

@section('scripts')

<script>
    
    var database = firebase.firestore();
    var ref = database.collection('settings').doc("DineinForRestaurant");

    $(document).ready(function(){
        jQuery("#data-table_processing").show();
        ref.get().then( async function(snapshots){
          var dineinSetting = snapshots.data();

          if(dineinSetting == undefined){
                database.collection('settings').doc('DineinForRestaurant').set({});
          }

          try{
              if(dineinSetting.isEnabled){
                  $("#enable_dine_in_for_restaurant").prop('checked',true);
              }
              if(dineinSetting.isEnabledForCustomer){
                  $("#dine_in_customers").prop('checked',true);
              }
          }catch(error){

          }
          jQuery("#data-table_processing").hide();

        })

        $(".save_booking_table_btn").click(function(){

          var checkboxValue = $("#enable_dine_in_for_restaurant").is(":checked");
          var isEnabledForCustomer = $('#dine_in_customers').is(":checked");
              database.collection('settings').doc("DineinForRestaurant").update({'isEnabled':checkboxValue,'isEnabledForCustomer':isEnabledForCustomer}).then(function(result) {
                            window.location.href = '{{ url("settings/app/bookTable")}}';
                        
                });

                    

        })
    })

 
</script>




@endsection