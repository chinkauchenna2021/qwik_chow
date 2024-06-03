@extends('layouts.app')

@section('content')
<div class="page-wrapper">
    <div class="row page-titles">
        <div class="col-md-5 align-self-center">
            <h3 class="text-themecolor">{{trans('lang.create_role')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item"><a href="{{ url('role') }}">{{trans('lang.role_plural')}}</a>
                </li>

                <li class="breadcrumb-item active">{{trans('lang.create_role')}}</li>


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

        <form action="{{route('role.store')}}" method="post" id="roleForm">
            @csrf
            <div class="row restaurant_payout_create">

                <div class="restaurant_payout_create-inner">

                    <fieldset>
                        <legend>{{trans('lang.role_details')}}</legend>
                            <div class="form-group row width-100 d-flex">
                                <label class="col-3 control-label">{{trans('lang.name')}}</label>
                                <div class="col-6">
                                    <input type="text" class="form-control" id="name" name="name">
                                </div>
                                <div class="col-6 text-right">
                                    <label for="permissions" class="form-label">{{trans('lang.assign_permissions')}}</label>
                                    <div class="text-right">
                                        <input type="checkbox" name="all_permission" id="all_permission">
                                        <label class="control-label" for="all_permission">{{trans('lang.all_permissions')}}</label>
                                    </div>
                                </div>
                            
                            </div>

                        <div class="form-group row width-100">

                            <div class="role-table width-100">
                                <div class="col-12">
                                    <table class="table table-striped">
                                        <thead>
                                            <th>Menu</th>
                                            <th>Permission</th>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.god_eye')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="god-eye" value="map" name="god-eye[]" class="permission">
                                                    <label class="control-label2" for="god-eye">{{trans('lang.view')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.role_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="role-list" value="role.index" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="role-save" value="role.save" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-save">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="role-store" value="role.store" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-store">{{trans('lang.store')}}</label>
                                                    
                                                    <input type="checkbox" id="role-edit" value="role.edit" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-edit">{{trans('lang.edit')}}</label>

                                                    <input type="checkbox" id="role-update" value="role.update" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-update">{{trans('lang.update')}}</label>
                                
                                                    <input type="checkbox" id="role-delete" value="role.delete" name="roles[]" class="permission">
                                                    <label class=" control-label2" for="role-delete">{{trans('lang.delete')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.admin_plural')}}</strong>
                                
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="admin-list" value="admin.users" name="admins[]" class="permission">
                                                    <label class=" control-label2" for="admin-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="admin-create" value="admin.users.create" name="admins[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="admin-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="admin-store" value="admin.users.store" name="admins[]" class="permission">
                                                    <label class=" control-label2" for="admin-store">{{trans('lang.store')}}</label>
                                
                                                    <input type="checkbox" id="admin-edit" value="admin.users.edit" name="admins[]" class="permission">
                                                    <label class=" control-label2" for="admin-edit">{{trans('lang.edit')}}</label>
                                
                                                    <input type="checkbox" id="admin-update" value="admin.users.update" name="admins[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="admin-update">{{trans('lang.update')}}</label>
                                
                                                    <input type="checkbox" id="admin-delete" value="admin.users.delete" name="admins[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="admin-delete">{{trans('lang.delete')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.user_customer')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="user-list" value="users" name="users[]" class="permission">
                                                    <label class=" control-label2" for="user-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="user-create" value="users.create" name="users[]" class="permission">
                                                    <label class=" control-label2" for="user-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="user-edit" value="users.edit" name="users[]" class="permission">
                                                    <label class=" control-label2" for="user-edit">{{trans('lang.edit')}}</label>
                                
                                                    <input type="checkbox" id="user-view" value="users.view" name="users[]" class="permission">
                                                    <label class=" control-label2" for="user-view">{{trans('lang.view')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.owner_vendor')}}</strong>
                                
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="vendors-list" value="vendors" name="vendors[]" class="permission">
                                                    <label class=" control-label2" for="vendors-list">{{trans('lang.list')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.restaurant_plural')}}</strong>
                                
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="restaurants-list" value="restaurants" name="restaurants[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="restaurants-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="restaurants-create" value="restaurants.create" name="restaurants[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="restaurants-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="restaurants-edit" value="restaurants.edit" name="restaurants[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="restaurants-edit">{{trans('lang.edit')}}</label>
                                
                                                    <input type="checkbox" id="restaurants-view" value="restaurants.view" name="restaurants[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="restaurants-view">{{trans('lang.view')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.driver_plural')}}</strong>
                                
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="drivers-list" value="drivers" name="drivers[]" class="permission">
                                                    <label class=" control-label2" for="drivers-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="drivers-create" value="drivers.create" name="drivers[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="drivers-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="drivers-edit" value="drivers.edit" name="drivers[]" class="permission">
                                                    <label class=" control-label2" for="drivers-edit">{{trans('lang.edit')}}</label>
                                
                                                    <input type="checkbox" id="drivers-view" value="drivers.view" name="drivers[]" class="permission">
                                                    <label class=" control-label2" for="drivers-view">{{trans('lang.view')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.reports_sale')}}</strong>
                                
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="report" value="report.index" name="reports[]" class="permission">
                                                    <label class="control-label2" for="report">{{trans('lang.create')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.category_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="categories-list" value="categories" name="category[]" class="permission">
                                                    <label class=" control-label2" for="categories-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="categories-create" value="categories.create" name="category[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="categories-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="categories-edit" value="categories.edit" name="category[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="categories-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.food_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="foods-list" value="foods" name="foods[]" class="permission">
                                                    <label class=" control-label2" for="foods-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="foods-create" value="foods.create" name="foods[]" class="permission">
                                                    <label class=" control-label2" for="foods-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="foods-edit" value="foods.edit" name="foods[]" class="permission">
                                                    <label class=" control-label2" for="foods-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.item_attribute_id')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="attributes-list" value="attributes" name="item-attribute[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="attributes-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="attributes-create" value="attributes.create" name="item-attribute[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="attributes-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="attributes-edit" value="attributes.edit" name="item-attribute[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="attributes-edit">{{trans('lang.edit')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.review_attribute_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="reviewattributes-list" value="reviewattributes" name="review-attribute[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="reviewattributes-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="reviewattributes-create" value="reviewattributes.create"
                                                        name="review-attribute[]" class="permission">
                                                    <label class=" control-label2" for="reviewattributes-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="reviewattributes-edit" value="reviewattributes.edit"
                                                        name="review-attribute[]" class="permission">
                                                    <label class=" control-label2" for="reviewattributes-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.order_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="orders-list" value="orders" name="orders[]" class="permission">
                                                    <label class=" control-label2" for="orders-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="orders-print" value="vendors.orderprint" name="orders[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="orders-print">{{trans('lang.print')}}</label>
                                
                                                    <input type="checkbox" id="orders-edit" value="orders.edit" name="orders[]" class="permission">
                                                    <label class=" control-label2" for="orders-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.dinein_order')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="dinein-list" value="restaurants.booktable" name="dinein-orders[]" class="permission">
                                                    <label class=" control-label2" for="dinein-list">{{trans('lang.list')}}</label>
                                                                
                                                    <input type="checkbox" id="dinein-edit" value="booktable.edit" name="dinein-orders[]" class="permission">
                                                    <label class=" control-label2" for="dinein-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.gift_card_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="gift-card" value="gift-card.index" name="gift-cards[]" class="permission">
                                                    <label class=" control-label2" for="gift-card">{{trans('lang.list')}}</label>
                                                    <input type="checkbox" id="gift-card-save" value="gift-card.save" name="gift-cards[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="gift-card-save">{{trans('lang.create')}}</label>
                                                    <input type="checkbox" id="gift-card-edit" value="gift-card.edit" name="gift-cards[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="gift-card-edit">{{trans('lang.edit')}}</label>

                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.coupon_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="coupons" value="coupons" name="coupons[]" class="permission">
                                                    <label class=" control-label2" for="coupons">{{trans('lang.list')}}</label>
                                                    <input type="checkbox" id="coupons-create" value="coupons.create" name="coupons[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="coupons-create">{{trans('lang.create')}}</label>
                                                    <input type="checkbox" id="coupons-edit" value="coupons.edit" name="coupons[]" class="permission">
                                                    <label class=" control-label2" for="coupons-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.general_notification')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="notification-list" value="notification" name="general-notifications[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="notification-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="notification-send" value="notification.send"
                                                        name="general-notifications[]" class="permission">
                                                    <label class=" control-label2" for="notification-send">{{trans('lang.create')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.dynamic_notification')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="dynamicnotification-list" value="dynamic-notification.index"
                                                        name="dynamic-notifications[]" class="permission">
                                                    <label class=" control-label2" for="dynamicnotification-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="dynamicnotification-save" value="dynamic-notification.save"
                                                        name="dynamic-notifications[]" class="permission">
                                                    <label class=" control-label2"
                                                        for="dynamicnotification-save">{{trans('lang.edit')}}</label>
                                                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.payment_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="payments" value="payments" name="payments[]" class="permission">
                                                    <label class=" control-label2" for="payments">{{trans('lang.list')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.restaurants_payout_plural')}}</label>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="restaurant-payouts-list" value="restaurantsPayouts"
                                                        name="restaurant-payouts[]" class="permission">
                                                    <label class=" control-label2" for="restaurant-payouts-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="restaurant-payouts-create" value="restaurantsPayouts.create"
                                                        name="restaurant-payouts[]" class="permission">
                                                    <label class=" control-label2"
                                                        for="restaurant-payouts-create">{{trans('lang.create')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.driver_plural')}}
                                                        {{trans('lang.payment_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="driver-payments-list" value="driver.driverpayments"
                                                        name="driver-payments[]" class="permission" >
                                                    <label class=" control-label2" for="driver-payments-list">{{trans('lang.list')}}</label>
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.drivers_payout')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="driver-payouts-list" value="driversPayouts" name="driver-payouts[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="driver-payouts-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="driver-payouts-create" value="driversPayouts.create"
                                                        name="driver-payouts[]" class="permission">
                                                    <label class=" control-label2" for="driver-payouts-create">{{trans('lang.create')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.wallet_transaction')}}</strong>
                                                </td>
                                                <td>
                                
                                                    <input type="checkbox" id="wallet-transaction-list" value="walletstransaction"
                                                        name="wallet-transaction[]" class="permission">
                                                    <label class=" control-label2" for="wallet-transaction-list">{{trans('lang.list')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.payout_request')}}</strong>
                                                </td>
                                                <td>
                                
                                                    <input type="checkbox" id="payout-request-driver" value="payoutRequests.drivers"
                                                        name="payout-request[]" class="permission">
                                                    <label class=" control-label2" for="payout-request-driver">{{trans('lang.driver')}}
                                                        {{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="payout-request-restaurant" value="payoutRequests.restaurants"
                                                        name="payout-request[]" class="permission" >
                                                    <label class=" control-label2" for="payout-request-restaurant">{{trans('lang.restaurant')}}
                                                        {{trans('lang.list')}}</label>
                                
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.menu_items')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="banners" value="setting.banners" name="banners[]" class="permission">
                                                    <label class=" control-label2" for="banners">{{trans('lang.list')}}</label>
                                                    <input type="checkbox" id="banners-create" value="setting.banners.create" name="banners[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="banners-create">{{trans('lang.create')}}</label>
                                                    <input type="checkbox" id="banners-edit" value="setting.banners.edit" name="banners[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="banners-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.cms_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="cms" value="cms" name="cms[]" class="permission">
                                                    <label class=" control-label2" for="cms">{{trans('lang.list')}}</label>
                                                    <input type="checkbox" id="cms-create" value="cms.create" name="cms[]" class="permission">
                                                    <label class=" control-label2" for="cms-create">{{trans('lang.create')}}</label>
                                                    <input type="checkbox" id="cms-edit" value="cms.edit" name="cms[]" class="permission">
                                                    <label class=" control-label2" for="cms-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.email_templates')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="email-template" value="email-templates.index" name="email-template[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="email-template">{{trans('lang.list')}}</label>
                                                    <input type="checkbox" id="email-template-edit" value="email-templates.edit" name="email-template[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="email-template-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.app_setting_globals')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="global-setting" value="settings.app.globals" name="global-setting[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="global-setting">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.currency_plural')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="currency-list" value="currencies" name="currency[]" class="permission">
                                                    <label class=" control-label2" for="currency-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="currency-create" value="currencies.create" name="currency[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="currency-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="currency-edit" value="currencies.edit" name="currency[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="currency-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.payment_methods')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="payment-method-list" value="payment-method" name="payment-method[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="payment-method-list">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.restaurant_admin_commission')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="admin-commission" value="settings.app.adminCommission"
                                                        name="admin-commission[]" class="permission">
                                                    <label class=" control-label2" for="admin-commission">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.radios_configuration')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="radius" value="settings.app.radiusConfiguration" name="radius[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="radius">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.dine_in_future_setting')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="dinein" value="settings.app.bookTable" name="dinein[]" class="permission">
                                                    <label class=" control-label2" for="dinein">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.vat_setting')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="tax-list" value="tax" name="tax[]" class="permission">
                                                    <label class=" control-label2" for="tax-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="tax-create" value="tax.create" name="tax[]" class="permission">
                                                    <label class=" control-label2" for="tax-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="tax-edit" value="tax.edit" name="tax[]" class="permission">
                                                    <label class=" control-label2" for="tax-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                        <strong>{{trans('lang.deliveryCharge')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="delivery-charge" value="settings.app.deliveryCharge"
                                                        name="delivery-charge[]" class="permission">
                                                    <label class=" control-label2" for="delivery-charge">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.languages')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="language-list" value="settings.app.languages" name="language[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="language-list">{{trans('lang.list')}}</label>
                                
                                                    <input type="checkbox" id="language-create" value="settings.app.languages.create" name="language[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="language-create">{{trans('lang.create')}}</label>
                                
                                                    <input type="checkbox" id="language-edit" value="settings.app.languages.edit" name="language[]"
                                                        class="permission" >
                                                    <label class=" control-label2" for="language-edit">{{trans('lang.edit')}}</label>
                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.special_offer')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="special-offer" value="setting.specialOffer" name="special-offer[]"
                                                        class="permission">
                                                    <label class=" control-label2" for="special-offer">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.terms_and_conditions')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="terms" value="termsAndConditions" name="terms[]" class="permission">
                                                    <label class=" control-label2" for="terms">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.privacy_policy')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="privacy" value="privacyPolicy" name="privacy[]" class="permission">
                                                    <label class=" control-label2" for="privacy">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.homepageTemplate')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="home-page" value="homepageTemplate" name="home-page[]" class="permission">
                                                    <label class=" control-label2" for="home-page">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <strong>{{trans('lang.footer_template')}}</strong>
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="footer" value="footerTemplate" name="footer[]" class="permission">
                                                    <label class=" control-label2" for="footer">{{trans('lang.update')}}</label>
                                                </td>
                                            </tr>
                                
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>

                    </fieldset>
                </div>

            </div>

        </div>
        <div class="form-group col-12 text-center btm-btn">
            <button type="button" class="btn btn-primary save_role"><i class="fa fa-save"></i> {{
                trans('lang.save')}}
            </button>
            <a href="{{url('role')}}" class="btn btn-default"><i class="fa fa-undo"></i>{{
                trans('lang.cancel')}}</a>
        </div>
      <form>

    </div>

    @endsection

    @section('scripts')

    <script>

        $(".save_role").click(async function () {

            $(".success_top").hide();
            $(".error_top").hide();
            var name = $("#name").val();

            if (name == "") {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.user_name_help')}}</p>");
                window.scrollTo(0, 0);
                return false;
            }
            else{
                $('form#roleForm').submit();

            } 

        });

                $('#all_permission').on('click', function () {

                    if ($(this).is(':checked')) {
                        $.each($('.permission'), function () {
                            $(this).prop('checked', true);
                        });
                    } else {
                        $.each($('.permission'), function () {
                            $(this).prop('checked', false);
                        });
                    }

                });


    </script>

    @endsection