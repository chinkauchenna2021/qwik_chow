@extends('layouts.app')

@section('content')

<div class="page-wrapper">


    <div class="row page-titles">

        <div class="col-md-5 align-self-center">

            <h3 class="text-themecolor restaurantTitle">{{trans('lang.food_plural')}}</h3>

        </div>

        <div class="col-md-7 align-self-center">

            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{url('/dashboard')}}">{{trans('lang.dashboard')}}</a></li>
                <li class="breadcrumb-item active">{{trans('lang.food_plural')}}</li>
            </ol>

        </div>

        <div>

        </div>

    </div>


    <div class="container-fluid">

        <div class="row">

            <div class="col-12">


                <?php if ($id != '') { ?>
                    <div class="menu-tab">
                        <ul>
                            <li>
                                <a href="{{route('restaurants.view',$id)}}">{{trans('lang.tab_basic')}}</a>
                            </li>
                            <li class="active">
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
                            <li>
                                <a href="{{route('restaurants.booktable',$id)}}">{{trans('lang.dine_in_future')}}</a>
                            </li>

                        </ul>
                    </div>
                <?php } ?>

                <div class="card">
                    <div class="card-header">
                        <ul class="nav nav-tabs align-items-end card-header-tabs w-100">
                            <li class="nav-item">
                                <a class="nav-link active" href="{!! url()->current() !!}"><i
                                            class="fa fa-list mr-2"></i>{{trans('lang.food_table')}}</a>
                            </li>
                            <?php if ($id != '') { ?>
                                <li class="nav-item">
                                    <a class="nav-link" href="{!! route('foods.create') !!}/{{$id}}"><i
                                                class="fa fa-plus mr-2"></i>{{trans('lang.food_create')}}</a>
                                </li>
                            <?php } else { ?>
                                <li class="nav-item">
                                    <a class="nav-link" href="{!! route('foods.create') !!}"><i
                                                class="fa fa-plus mr-2"></i>{{trans('lang.food_create')}}</a>
                                </li>
                            <?php } ?>

                        </ul>
                    </div>
                    <div class="card-body">

                        <div id="data-table_processing" class="dataTables_processing panel panel-default"
                             style="display: none;">Processing...
                        </div>

                        <!--<div id="users-table_filter" class="pull-right"><label>{{trans('lang.search_by')}}
                            <select name="selected_search" id="selected_search" class="form-control input-sm">
                                <option value="title">{{trans('lang.title')}}</option>

                                <option value="restaurant">{{trans('lang.food_restaurant_id')}}</option>
                                <option value="category">{{trans('lang.category')}}</option>
                            </select>
                            <div class="form-group">
                                        <input type="search" id="search" class="search form-control"
                                               placeholder="Search">
                                        <select id="category_search_dropdown" class="form-control">
                                            <option value="All">
                                                Select Category
                                            </option>
                                        </select>



                            </div>
                            <button onclick="searchtext();" class="btn btn-warning btn-flat">
                                    {{trans('lang.search')}}
                                </button>&nbsp;<button onclick="searchclear();"
                                                       class="btn btn-warning btn-flat">
                                    {{trans('lang.clear')}}
                                </button>
                        </div>-->

                        <div class="table-responsive m-t-10">


                            <table id="foodTable"
                                   class="display nowrap table table-hover table-striped table-bordered table table-striped"
                                   cellspacing="0" width="100%">

                                <thead>

                                <tr>
                                    <th class="delete-all"><input type="checkbox" id="is_active"><label
                                                class="col-3 control-label" for="is_active">
                                            <a id="deleteAll" class="do_not_delete" href="javascript:void(0)"><i
                                                        class="fa fa-trash"></i> {{trans('lang.all')}}</a></label></th>
                                    <th>{{trans('lang.food_image')}}</th>
                                    <th>{{trans('lang.food_name')}}</th>
                                    <th>{{trans('lang.food_price')}}</th>
                                    <?php if ($id == '') { ?>
                                        <th>{{trans('lang.food_restaurant_id')}}</th>
                                    <?php } ?>

                                    <th>{{trans('lang.food_category_id')}}</th>
                                    <th>{{trans('lang.food_publish')}}</th>
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

</div>
</div>

@endsection

@section('scripts')

<script type="text/javascript">

    const urlParams = new URLSearchParams(location.search);
    for (const [key, value] of urlParams) {

        if (key == 'categoryID') {
            var categoryID = value;
        } else {
            var categoryID = '';
        }

    }
    var database = firebase.firestore();
    var offest = 1;
    var pagesize = 10;
    var end = null;
    var endarray = [];
    var start = null;
    var user_number = [];
    var currentCurrency = '';
    var currencyAtRight = false;
    var decimal_degits = 0;
    var storage = firebase.storage();
    var storageRef = firebase.storage().ref('images');

    if (categoryID != '' && categoryID != undefined) {
        var ref = database.collection('vendor_products').where('categoryID', '==', categoryID);
    } else {
        <?php if($id != ''){ ?>
        var ref = database.collection('vendor_products').where('vendorID', '==', '<?php echo $id; ?>');
        const getStoreName = getStoreNameFunction('<?php echo $id; ?>');
        <?php }else{ ?>
        var ref = database.collection('vendor_products');
        <?php } ?>
    }
    ref = ref.orderBy('name');

    var refCurrency = database.collection('currencies').where('isActive', '==', true);
    var append_list = '';

    refCurrency.get().then(async function (snapshots) {
        var currencyData = snapshots.docs[0].data();
        currentCurrency = currencyData.symbol;
        currencyAtRight = currencyData.symbolAtRight;

        if (currencyData.decimal_degits) {
            decimal_degits = currencyData.decimal_degits;
        }
    });

    var placeholderImage = '';
    var placeholder = database.collection('settings').doc('placeHolderImage');
    placeholder.get().then(async function (snapshotsimage) {
        var placeholderImageData = snapshotsimage.data();
        placeholderImage = placeholderImageData.image;
    })


    $(document).ready(function () {
        $('#category_search_dropdown').hide();

        $(document.body).on('click', '.redirecttopage', function () {
            var url = $(this).attr('data-url');
            window.location.href = url;
        });

        var inx = parseInt(offest) * parseInt(pagesize);
        jQuery("#data-table_processing").show();

        append_list = document.getElementById('append_list1');
        append_list.innerHTML = '';
        ref.get().then(async function (snapshots) {
            var html = '';

            html = await buildHTML(snapshots);

            if (html != '') {
                append_list.innerHTML = html;
                start = snapshots.docs[snapshots.docs.length - 1];
                endarray.push(snapshots.docs[0]);
                if (snapshots.docs.length < pagesize) {
                    jQuery("#data-table_paginate").hide();
                }
            }

            <?php if($id == ''){ ?>

            $('#foodTable').DataTable({
                order: [],
                columnDefs: [

                    {orderable: false, targets: [0, 1, 4, 5, 6, 7]},

                ],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                //responsive: true
            });
            <?php
            }else{?>

            $('#foodTable').DataTable({
                order: [],
                columnDefs: [
                    {orderable: false, targets: [0, 1, 4, 5, 6]},

                ],
                "language": {
                    "zeroRecords": "{{trans("lang.no_record_found")}}",
                    "emptyTable": "{{trans("lang.no_record_found")}}"
                },
                //responsive: true
            });
            <?php }?>


            jQuery("#data-table_processing").hide();
        });

    });


    async function buildHTML(snapshots) {
        var html = '';
        await Promise.all(snapshots.docs.map(async (listval) => {
            var val = listval.data();

            var getData = await getListData(val);
            html += getData;
        }));
        return html;
    }

    async function getListData(val) {
        var html = '';
        html = html + '<tr>';
        newdate = '';
        var imageHtml='';
        var id = val.id;
        var route1 = '{{route("foods.edit",":id")}}';
        route1 = route1.replace(':id', id);

        <?php if($id != ''){ ?>

        route1 = route1 + '?eid={{$id}}';

        <?php }?>
        if (val.photos != '') {
            imageHtml = '<img class="rounded" style="width:50px" src="' + val.photo + '" alt="image">';

           /* await  checkIfImageExists(val.photo, async(exists) => {
                if (exists) {
                    imageHtml = '<img class="rounded" style="width:50px" src="' + val.photo + '" alt="image">';
                    console.log('Image exists. ')
                } else {
                    imageHtml = '<img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image">';
                    console.error('Image does not exists.')
                }
              //html = html + '<td>' + imageHtml + '</td>';

            });*/
            
        } else if (val.photo != '') {
            imageHtml = '<img class="rounded" style="width:50px" src="' + val.photo + '" alt="image">';

           /*await checkIfImageExists(val.photo, (exists) => {
                if (exists) {
                     imageHtml= '<img class="rounded" style="width:50px" src="' + val.photo + '" alt="image">';
                    console.log('Image exists. ')
                } else {
                     imageHtml ='<img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image">';
                    console.error('Image does not exists.')
                }

               // html = html + '<td>'+imageHtml+'</td>';

            });*/

        } else {
             imageHtml = '<img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image">';

            //html = html + '<td><img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image"></td>';
        }

        html = html + '<td class="delete-all"><input type="checkbox" id="is_open_' + id + '" class="is_open" dataId="' + id + '"><label class="col-3 control-label"\n' +
            'for="is_open_' + id + '" ></label></td>';

        html = html + '<td>'+imageHtml+'</td>';
   
        html = html + '<td data-url="' + route1 + '" class="redirecttopage">' + val.name + '</td>';


        if (val.hasOwnProperty('disPrice') && val.disPrice != '' && val.disPrice != '0') {
            if (currencyAtRight) {
                html = html + '<td class="text-green">' + parseFloat(val.disPrice).toFixed(decimal_degits) + '' + currentCurrency + '  <s>' + parseFloat(val.price).toFixed(decimal_degits) + '' + currentCurrency + '</s></td>';

            } else {
                html = html + '<td class="text-green">' + '' + currentCurrency + parseFloat(val.disPrice).toFixed(decimal_degits) + '  <s>' + currentCurrency + '' + parseFloat(val.price).toFixed(decimal_degits) + '</s> </td>';

            }

        } else {

            if (currencyAtRight) {
                html = html + '<td class="text-green">' + parseFloat(val.price).toFixed(decimal_degits) + '' + currentCurrency + '</td>';
            } else {
                html = html + '<td class="text-green">' + currentCurrency + '' + parseFloat(val.price).toFixed(decimal_degits) + '</td>';
            }
        }

        <?php if($id == ''){ ?>
        const restaurant = await productRestaurant(val.vendorID);
        var restaurantroute = '{{route("restaurants.view",":id")}}';
        restaurantroute = restaurantroute.replace(':id', val.vendorID);

        html = html + '<td><a href="' + restaurantroute + '">' + restaurant + '</a></td>';
        <?php }?>


        const category = await productCategory(val.categoryID);
        var caregoryroute = '{{route("categories.edit",":id")}}';
        caregoryroute = caregoryroute.replace(':id', val.categoryID);

        html = html + '<td><a href="' + caregoryroute + '">' + category + '</a></td>';
        if (val.publish) {
            html = html + '<td><label class="switch"><input type="checkbox" checked id="' + val.id + '" name="publish"><span class="slider round"></span></label></td>';
        } else {
            html = html + '<td><label class="switch"><input type="checkbox" id="' + val.id + '" name="publish"><span class="slider round"></span></label></td>';
        }
        html = html + '<td class="action-btn"><a href="' + route1 + '" class="link-td"><i class="fa fa-edit"></i></a><a id="' + val.id + '" name="food-delete" href="javascript:void(0)" class="link-td do_not_delete"><i class="fa fa-trash"></i></a></td>';

        html = html + '</tr>';

        return html;
    }
/*async function checkImage(imageurl){
    return new Promise((resolve) => {
        imageurl.onerror = () => resolve(false);
        imageurl.onload = () => resolve(true);
    });
}*/
async function checkIfImageExists(url, callback) {
  const img = new Image();
  img.src = url;
  
  if (img.complete) {
     callback(true);
  } else {
    img.onload = () => {
       callback(true);
    };
    
    img.onerror = () => {
       callback(false); 
    };
  }
}

    $(document).on("click", "input[name='publish']", function (e) {
        var ischeck = $(this).is(':checked');
        var id = this.id;
        if (ischeck) {
            database.collection('vendor_products').doc(id).update({'publish': true}).then(function (result) {

            });
        } else {
            database.collection('vendor_products').doc(id).update({'publish': false}).then(function (result) {

            });
        }

    });

    async function productRestaurant(restaurant) {
        var productRestaurant = '';
        await database.collection('vendors').where("id", "==", restaurant).get().then(async function (snapshotss) {


            if (snapshotss.docs[0]) {
                var restaurant_data = snapshotss.docs[0].data();
                productRestaurant = restaurant_data.title;

                //jQuery(".restaurant_" + restaurant).html(productRestaurant);
            }
        });
        return productRestaurant;
    }

    async function getStoreNameFunction(vendorId) {
        var vendorName = '';
        await database.collection('vendors').where('id', '==', vendorId).get().then(async function (snapshots) {
            if (!snapshots.empty) {
                var vendorData = snapshots.docs[0].data();

                vendorName = vendorData.title;
                $('.restaurantTitle').html('{{trans("lang.food_plural")}} - ' + vendorName);

                if (vendorData.dine_in_active == true) {
                    $(".dine_in_future").show();
                }
            }
        });

        return vendorName;

    }

    async function productCategory(category) {
        var productCategory = '';
        await database.collection('vendor_categories').where("id", "==", category).get().then(async function (snapshotss) {

            if (snapshotss.docs[0]) {
                var category_data = snapshotss.docs[0].data();
                productCategory = category_data.title;
                // console.log(productCategory);
                //jQuery(".category_" + category).html(productCategory);
            }
        });
        return productCategory;
    }

    function prev() {
        if (endarray.length == 1) {
            return false;
        }
        end = endarray[endarray.length - 2];
        if (end != undefined || end != null) {
            jQuery("#data-table_processing").show();
            if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {

                listener = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAt(end).get();

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

            } else if (jQuery("#selected_search").val() == 'category' && jQuery("#category_search_dropdown").val().trim() != '') {

                if (jQuery("#category_search_dropdown").val() == "All") {
                    listener = ref.limit(pagesize).startAt(end).get();
                } else {
                    listener = ref.orderBy('categoryID').limit(pagesize).startAt(jQuery("#category_search_dropdown").val()).endAt(jQuery("#category_search_dropdown").val() + '\uf8ff').startAt(end).get();

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

            } else if (jQuery("#selected_search").val() == 'restaurant' && jQuery("#search").val().trim() != '') {
                title = jQuery("#search").val();

                database.collection('vendors').where('title', '==', title).get().then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var storedata = snapshots.docs[0].data();

                        listener = ref.orderBy('vendorID').limit(pagesize).startAt(storedata.id).endAt(storedata.id + '\uf8ff').startAt(end).get();

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
                    } else {
                        jQuery("#data-table_processing").hide();
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
            jQuery("#data-table_processing").show();

            if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {

                listener = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').startAfter(start).get();

            } else if (jQuery("#selected_search").val() == 'category' && jQuery("#category_search_dropdown").val().trim() != '') {

                if (jQuery("#category_search_dropdown").val() == "All") {
                    listener = ref.limit(pagesize).startAfter(start).get();
                } else {
                    listener = ref.orderBy('categoryID').limit(pagesize).startAt(jQuery("#category_search_dropdown").val()).endAt(jQuery("#category_search_dropdown").val() + '\uf8ff').startAfter(start).get();

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

            } else if (jQuery("#selected_search").val() == 'restaurant' && jQuery("#search").val().trim() != '') {
                title = jQuery("#search").val();

                database.collection('vendors').where('title', '==', title).get().then(async function (snapshots) {

                    if (snapshots.docs.length > 0) {
                        var storedata = snapshots.docs[0].data();

                        listener = ref.orderBy('vendorID').limit(pagesize).startAt(storedata.id).endAt(storedata.id + '\uf8ff').startAfter(start).get();

                        listener.then((snapshotsInner) => {

                            html = '';
                            html = buildHTML(snapshotsInner);

                            jQuery("#data-table_processing").hide();
                            if (html != '') {
                                append_list.innerHTML = html;
                                start = snapshotsInner.docs[snapshotsInner.docs.length - 1];

                                if (endarray.indexOf(snapshotsInner.docs[0]) != -1) {
                                    endarray.splice(endarray.indexOf(snapshotsInner.docs[0]), 1);
                                }
                                endarray.push(snapshotsInner.docs[0]);
                            }
                        });
                    } else {
                        jQuery("#data-table_processing").hide();
                    }

                });

            } else {
                listener = ref.startAfter(start).limit(pagesize).get();

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
    }


    function searchtext() {
        var offest = 1;
        jQuery("#data-table_processing").show();

        append_list.innerHTML = '';

        if (jQuery("#selected_search").val() == 'title' && jQuery("#search").val().trim() != '') {

            wherequery = ref.orderBy('name').limit(pagesize).startAt(jQuery("#search").val()).endAt(jQuery("#search").val() + '\uf8ff').get();
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

        } else if (jQuery("#selected_search").val() == 'restaurant' && jQuery("#search").val().trim() != '') {
            title = jQuery("#search").val();

            database.collection('vendors').where('title', '==', title).get().then(async function (snapshots) {

                if (snapshots.docs.length > 0) {
                    var storedata = snapshots.docs[0].data();

                    wherequery = ref.orderBy('vendorID').limit(pagesize).startAt(storedata.id).endAt(storedata.id + '\uf8ff').get();

                    wherequery.then((snapshotsInner) => {
                        html = '';
                        html = buildHTML(snapshotsInner);
                        jQuery("#data-table_processing").hide();
                        if (html != '') {
                            append_list.innerHTML = html;
                            start = snapshotsInner.docs[snapshotsInner.docs.length - 1];
                            endarray.push(snapshotsInner.docs[0]);
                            if (snapshotsInner.docs.length < pagesize) {

                                jQuery("#data-table_paginate").hide();
                            } else {

                                jQuery("#data-table_paginate").show();
                            }
                        }
                    });
                } else {
                    jQuery("#data-table_processing").hide();
                }

            });


        } else if (jQuery("#selected_search").val() == 'category' && jQuery("#category_search_dropdown").val().trim() != '') {

            if (jQuery("#category_search_dropdown").val() == "All") {
                wherequery = ref.limit(pagesize).get();
            } else {
                wherequery = ref.orderBy('categoryID').limit(pagesize).startAt(jQuery("#category_search_dropdown").val()).endAt(jQuery("#category_search_dropdown").val() + '\uf8ff').get();

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

    function searchclear() {
        jQuery("#search").val('');
        $('#category_search_dropdown').val("All").trigger('change');
        searchtext();
    }

    $(document).on("click", "a[name='food-delete']", function (e) {
        var id = this.id;
        database.collection('vendor_products').doc(id).delete().then(function (result) {
            window.location.href = '{{ url()->current() }}';
        });
    });

    $(document.body).on('change', '#selected_search', function () {

        if (jQuery(this).val() == 'category') {

            var ref_category = database.collection('vendor_categories');

            ref_category.get().then(async function (snapshots) {
                snapshots.docs.forEach((listval) => {
                    var data = listval.data();
                    $('#category_search_dropdown').append($("<option></option").attr("value", data.id).text(data.title));

                });

            });
            jQuery('#search').hide();
            jQuery('#category_search_dropdown').show();
        } else {
            jQuery('#search').show();
            jQuery('#category_search_dropdown').hide();

        }
    });

    $("#is_active").click(function () {
        $("#example24 .is_open").prop('checked', $(this).prop('checked'));
    });

    $("#deleteAll").click(function () {
        if ($('#example24 .is_open:checked').length) {

            if (confirm("{{trans('lang.selected_delete_alert')}}")) {
                jQuery("#data-table_processing").show();
                $('#example24 .is_open:checked').each(function () {
                    var dataId = $(this).attr('dataId');

                    database.collection('vendor_products').doc(dataId).delete().then(function () {
                        setTimeout(function () {
                            window.location.reload();
                        }, 7000);

                    });
                });
            }
        } else {
            alert("{{trans('lang.select_delete_alert')}}");
        }
    });

</script>


@endsection
