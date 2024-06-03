 @extends('layouts.app')

@section('content')
    <div class="page-wrapper">
        <div class="row page-titles">

            <div class="col-md-5 align-self-center">
                <h3 class="text-themecolor">{{trans('lang.food_plural')}}</h3>
            </div>
            <div class="col-md-7 align-self-center">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="index.php">{{trans('lang.dashboard')}}</a></li>
                    <?php if(isset($_GET['eid']) && $_GET['eid'] != ''){?>
                    <li class="breadcrumb-item"><a
                                href="{{route('restaurants.foods',$_GET['eid'])}}">{{trans('lang.food_plural')}}</a>
                    </li>
                    <?php }else{ ?>
                    <li class="breadcrumb-item"><a href="{!! route('foods') !!}">{{trans('lang.food_plural')}}</a></li>
                    <?php } ?>

                    <li class="breadcrumb-item active">{{trans('lang.food_edit')}}</li>
                </ol>
            </div>
        </div>

        <div>

            <div class="card-body">
                <div id="data-table_processing" class="dataTables_processing panel panel-default"
                     style="display: none;">{{trans('lang.processing')}}</div>
                <div class="error_top" style="display:none"></div>
                <div class="row restaurant_payout_create">
                    <div class="restaurant_payout_create-inner">

                        <fieldset>
                            <legend>{{trans('lang.food_information')}}</legend>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.food_name')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control food_name" required>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_name_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.food_price')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control food_price" required>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_price_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.food_discount')}}</label>
                                <div class="col-7">
                                    <input type="text" class="form-control food_discount">
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_discount_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-50 food_restaurant_div">
                                <label class="col-3 control-label">{{trans('lang.food_restaurant_id')}}</label>
                                <div class="col-7">
                                    <select id="food_restaurant" class="form-control" required>
                                        <option value="">{{trans('lang.select_restaurant')}}</option>
                                    </select>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_restaurant_id_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.food_category_id')}}</label>
                                <div class="col-7">
                                    <select id='food_category' class="form-control" required>
                                        <option value="">{{trans('lang.select_category')}}</option>
                                    </select>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_category_id_help") }}
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.item_quantity')}}</label>
                                <div class="col-7">
                                    <input type="number" class="form-control item_quantity" value="-1">
                                    <div class="form-text text-muted">
                                        {{ trans("lang.item_quantity_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-100" id="attributes_div">
                                <label class="col-3 control-label">{{trans('lang.item_attribute_id')}}</label>
                                <div class="col-7">
                                    <select id='item_attribute' class="form-control chosen-select" required
                                            multiple="multiple"
                                            onchange="selectAttribute();"></select>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <div class="item_attributes" id="item_attributes"></div>
                                <div class="item_variants" id="item_variants"></div>
                                <input type="hidden" id="attributes" value=""/>
                                <input type="hidden" id="variants" value=""/>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.food_image')}}</label>
                                <div class="col-7">
                                    <input type="file" id="product_image">
                                    <div class="placeholder_img_thumb product_image"></div>
                                    <div id="uploding_image"></div>
                                    <div class="form-text text-muted">
                                        {{ trans("lang.food_image_help") }}
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <label class="col-3 control-label">{{trans('lang.food_description')}}</label>
                                <div class="col-7">
                                    <textarea rows="8" class="form-control food_description"
                                              id="food_description"></textarea>
                                </div>
                            </div>
                            <div class="form-check width-100">
                                <input type="checkbox" class="food_publish" id="food_publish">
                                <label class="col-3 control-label"
                                       for="food_publish">{{trans('lang.food_publish')}}</label>
                            </div>

                            <div class="form-check width-100">
                                <input type="checkbox" class="food_nonveg" id="food_nonveg">
                                <label class="col-3 control-label" for="food_nonveg">{{ trans('lang.non_veg')}}</label>
                            </div>

                            <div class="form-check width-100">
                                <input type="checkbox" class="food_take_away_option" id="food_take_away_option">
                                <label class="col-3 control-label"
                                       for="food_take_away_option">{{trans('lang.food_take_away')}}</label>
                            </div>

                        </fieldset>

                        <fieldset>

                            <legend>{{trans('lang.ingredients')}}</legend>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.calories')}}</label>
                                <div class="col-7">
                                    <input type="number" class="form-control food_calories">
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.grams')}}</label>
                                <div class="col-7">
                                    <input type="number" class="form-control food_grams">
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.fats')}}</label>
                                <div class="col-7">
                                    <input type="number" class="form-control food_fats">
                                </div>
                            </div>

                            <div class="form-group row width-50">
                                <label class="col-3 control-label">{{trans('lang.proteins')}}</label>
                                <div class="col-7">
                                    <input type="number" class="form-control food_proteins">
                                </div>
                            </div>

                        </fieldset>


                        <fieldset>
                            <legend>{{trans('lang.food_add_one')}}</legend>

                            <div class="form-group add_ons_list extra-row">
                            </div>

                            <div class="form-group row width-100">
                                <div class="col-7">
                                    <button type="button" onclick="addOneFunction()" class="btn btn-primary"
                                            id="add_one_btn">{{trans('lang.food_add_one')}}</button>
                                </div>
                            </div>

                            <div class="form-group row width-100" id="add_ones_div" style="display:none">

                                <div class="row">
                                    <div class="col-6">
                                        <label class="col-3 control-label">{{trans('lang.food_title')}}</label>
                                        <div class="col-7">
                                            <input type="text" class="form-control add_ons_title">
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <label class="col-3 control-label">{{trans('lang.food_price')}}</label>
                                        <div class="col-7">
                                            <input type="number" class="form-control add_ons_price">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row save_add_one_btn width-100" style="display:none">
                                <div class="col-7">
                                    <button type="button" onclick="saveAddOneFunction()"
                                            class="btn btn-primary">{{trans('lang.save_add_ones')}}</button>
                                </div>
                            </div>

                        </fieldset>
                        <fieldset>
                            <legend>{{trans('lang.product_specification')}}</legend>

                            <div class="form-group product_specification extra-row">
                                <div class="row" id="product_specification_heading" style="display: none;">
                                    <div class="col-6">
                                        <label class="col-2 control-label">{{trans('lang.lable')}}</label>

                                    </div>
                                    <div class="col-6">
                                        <label class="col-3 control-label">{{trans('lang.value')}}</label>

                                    </div>
                                </div>
                            </div>

                            <div class="form-group row width-100">
                                <div class="col-7">
                                    <button type="button" onclick="addProductSpecificationFunction()"
                                            class="btn btn-primary"
                                            id="add_one_btn"> {{trans('lang.add_product_specification')}}</button>
                                </div>
                            </div>
                            <div class="form-group row width-100" id="add_product_specification_div"
                                 style="display:none">
                                <div class="row">
                                    <div class="col-6">
                                        <label class="col-2 control-label">{{trans('lang.lable')}}</label>
                                        <div class="col-7">
                                            <input type="text" class="form-control add_label">
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <label class="col-3 control-label">{{trans('lang.value')}}</label>
                                        <div class="col-7">
                                            <input type="text" class="form-control add_value">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row save_product_specification_btn width-100" style="display:none">
                                <div class="col-7">
                                    <button type="button" onclick="saveProductSpecificationFunction()"
                                            class="btn btn-primary">{{trans('lang.save_product_specification')}}</button>
                                </div>
                            </div>

                        </fieldset>
                    </div>
                </div>


                <div class="form-group col-12 text-center btm-btn">
                    <button type="button" class="btn btn-primary  save_food_btn"><i
                                class="fa fa-save"></i> {{trans('lang.save')}}</button>
                    <?php if(isset($_GET['eid']) && $_GET['eid'] != ''){?>
                    <a href="{{route('restaurants.foods',$_GET['eid'])}}" class="btn btn-default"><i
                                class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
                    <?php }else{ ?>
                    <a href="{!! route('foods') !!}" class="btn btn-default"><i
                                class="fa fa-undo"></i>{{trans('lang.cancel')}}</a>
                    <?php } ?>

                </div>
            </div>
        </div>
    </div>


@endsection

@section('scripts')

    <script>

        var id = "<?php echo $id;?>";
        var database = firebase.firestore();
        var ref = database.collection('vendor_products').doc(id);
        var storageRef = firebase.storage().ref('images');
        var storage = firebase.storage();

        var photo = "";
        var addOnesTitle = [];
        var addOnesPrice = [];
        var sizeTitle = [];
        var sizePrice = [];
        var attributes_list = [];
        var categories_list = [];
        var restaurant_list = [];
        var photos = [];
        var new_added_photos = [];
        var new_added_photos_filename = [];
        var photosToDelete = [];

        var product_specification = {};
        var placeholderImage = '';
        var productImagesCount = 0;
        var variant_photos=[];
        var variant_filename=[];
        var variantImageToDelete=[];
        var variant_vIds=[];
        var placeholder = database.collection('settings').doc('placeHolderImage');

        placeholder.get().then(async function (snapshotsimage) {
            var placeholderImageData = snapshotsimage.data();
            placeholderImage = placeholderImageData.image;
        })

        $(document).ready(function () {
            <?php if(isset($_GET['eid']) && $_GET['eid'] != ''){?>
            $(".food_restaurant_div").hide();
            <?php } else{?>
            $(".food_restaurant_div").show();
            <?php } ?>
            $("#attributes_div").show();
            jQuery(document).on("click", ".mdi-cloud-upload", function () {
                var variant = jQuery(this).data('variant');
                var fileurl = $('[id="variant_' + variant + '_url"]').val();
                if (fileurl) {
                    variantImageToDelete.push(fileurl);
                   /* firebase.storage().refFromURL(fileurl).delete();
                    console.log('Image Deleted');*/
                }
                console.log(variantImageToDelete);
                var photo_remove = $(this).attr('data-img');
                index = variant_photos.indexOf(photo_remove);
                if (index > -1) {
                    variant_photos.splice(index, 1); // 2nd parameter means remove one item only
                }
                var file_remove = $(this).attr('data-file');
                fileindex = variant_filename.indexOf(file_remove);
                if (fileindex > -1) {
                    variant_filename.splice(fileindex, 1); // 2nd parameter means remove one item only
                }
                variantindex = variant_vIds.indexOf(variant);
                if (variantindex > -1) {
                    variant_vIds.splice(variantindex, 1); // 2nd parameter means remove one item only
                }
                $('[id="variant_' + variant + '_url"]').val('');
                $('[id="file_' + variant + '"]').click();
            });

            jQuery(document).on("click", ".mdi-delete", function () {
                var variant = jQuery(this).data('variant');
                var fileurl = $('[id="variant_' + variant + '_url"]').val();
                if (fileurl) {
                    variantImageToDelete.push(fileurl);
                    /*firebase.storage().refFromURL(fileurl).delete();
                    console.log('Image Deleted');*/

                }
                console.log(variantImageToDelete);

                var photo_remove = $(this).attr('data-img');
                index = variant_photos.indexOf(photo_remove);
                if (index > -1) {
                    variant_photos.splice(index, 1); // 2nd parameter means remove one item only
                }
                var file_remove = $(this).attr('data-file');
                fileindex = variant_filename.indexOf(file_remove);
                if (fileindex > -1) {
                    variant_filename.splice(fileindex, 1); // 2nd parameter means remove one item only
                }
                variantindex = variant_vIds.indexOf(variant);
                if (variantindex > -1) {
                    variant_vIds.splice(variantindex, 1); // 2nd parameter means remove one item only
                }

                $('[id="variant_' + variant + '_image"]').empty();
                $('[id="variant_' + variant + '_url"]').val('');
            });
            jQuery("#data-table_processing").show();
            ref.get().then(async function (snapshots) {
                var product = snapshots.data();

                await database.collection('vendors').orderBy('title', 'asc').get().then(async function (snapshots) {

                    snapshots.docs.forEach((listval) => {
                        var data = listval.data();
                        restaurant_list.push(data);
                        if (data.id == product.vendorID) {
                            $('#food_restaurant').append($("<option selected></option>")
                                .attr("value", data.id)
                                .text(data.title));
                        } else {
                            $('#food_restaurant').append($("<option></option>")
                                .attr("value", data.id)
                                .text(data.title));
                        }


                    })

                });

                await database.collection('vendor_categories').where('publish', '==', true).get().then(async function (snapshots) {

                    snapshots.docs.forEach((listval) => {
                        var data = listval.data();
                        categories_list.push(data);
                        if (data.id == product.categoryID) {
                            $('#food_category').append($("<option selected></option>")
                                .attr("value", data.id)
                                .text(data.title));
                        } else {
                            $('#food_category').append($("<option></option>")
                                .attr("value", data.id)
                                .text(data.title));
                        }


                    })

                });
                var selected_attributes = [];
                if (product.item_attribute != null) {
                    $("#attributes_div").show();
                    $.each(product.item_attribute.attributes, function (index, attribute) {
                        selected_attributes.push(attribute.attribute_id);
                    });

                    $('#attributes').val(JSON.stringify(product.item_attribute.attributes));
                    $('#variants').val(JSON.stringify(product.item_attribute.variants));

                }

                var attributes = database.collection('vendor_attributes');

                attributes.get().then(async function (snapshots) {
                    snapshots.docs.forEach((listval) => {
                        var data = listval.data();
                        attributes_list.push(data);

                        var selected = '';
                        if ($.inArray(data.id, selected_attributes) !== -1) {
                            var selected = 'selected="selected"';
                        }
                        var option = '<option value="' + data.id + '" ' + selected + '>' + data.title + '</option>';
                        $('#item_attribute').append(option);
                    });
                    $("#item_attribute").show().chosen({"placeholder_text": "{{trans('lang.select_attribute')}}"});

                    if (product.item_attribute) {
                        $("#item_attribute").attr("onChange", "selectAttribute('" + btoa(JSON.stringify(product.item_attribute)) + "')");
                        selectAttribute(btoa(JSON.stringify(product.item_attribute)));
                    } else {
                        $("#item_attribute").attr("onChange", "selectAttribute()");
                        selectAttribute();
                    }
                });
                if (product.hasOwnProperty('product_specification')) {
                    product_specification = product.product_specification;
                    if (product_specification != null && product_specification != "") {
                        product_specification = {};
                        $.each(product.product_specification, function (key, value) {
                            product_specification[key] = value;
                        });
                    }

                    var count = 1;
                    for (var key in product.product_specification) {

                        $('#product_specification_heading').show();
                        $(".product_specification").append('<div class="row add_product_specification_iteam_' + count + '" style="margin-top:5px;" id="add_product_specification_iteam_' + key + '">' +
                            '<div class="col-5"><input class="form-control" type="text" value="' + key + '" disabled ></div>' +
                            '<div class="col-5"><input class="form-control" type="text" value="' + product.product_specification[key] + '" disabled ></div>' +
                            '<div class="col-2"><button class="btn" type="button" onclick="deleteProductSpecificationSingle(' + count + ')"><span class="fa fa-trash"></span></button></div></div>');
                        count++;
                    }
                }

                if (product.hasOwnProperty('photo')) {

                    photo = product.photo;

                    if (product.photos != undefined && product.photos != '') {
                        photos = product.photos;
                    } else {
                        if (photo != '' && photo != null) {
                            photos.push(photo);

                        }
                    }

                    if (photos != '' && photos != null) {
                        photos.forEach((element, index) => {
                            $(".product_image").append('<span class="image-item" id="photo_' + index + '"><span class="remove-btn" data-id="' + index + '" data-img="' + photos[index] + '" data-status="old"><i class="fa fa-remove"></i></span><img class="rounded" width="50px" id="" height="auto" src="' + photos[index] + '"></span>');
                        })
                    } else if (photo != '' && photo != null) {
                        $(".product_image").append('<span class="image-item" id="photo_1"><img class="rounded" width="50px" id="" height="auto" src="' + photo + '"></span>');


                    } else {

                        $(".product_image").append('<span class="image-item" id="photo_1"><img class="rounded" style="width:50px" src="' + placeholderImage + '" alt="image">');
                    }
                }

                $(".food_name").val(product.name);
                $(".food_price").val(product.price);
                $(".item_quantity").val(product.quantity);
                $(".food_discount").val(product.disPrice);
                if (product.hasOwnProperty("calories")) {
                    $(".food_calories").val(product.calories)
                }
                if (product.hasOwnProperty("grams")) {
                    $(".food_grams").val(product.grams);
                }
                if (product.hasOwnProperty("proteins")) {
                    $(".food_proteins").val(product.proteins)
                }
                if (product.hasOwnProperty("fats")) {
                    $(".food_fats").val(product.fats);
                }

                // $(".food_quantity").val(parseFloat(product.quantity));
                $("#food_description").val(product.description);
                if (product.publish) {
                    $(".food_publish").prop('checked', true);
                }

                if (product.nonveg) {

                    $(".food_nonveg").prop('checked', true);
                }
                if (product.takeawayOption) {
                    $(".food_take_away_option").prop('checked', true);
                }

                if (product.hasOwnProperty('addOnsTitle')) {
                    product.addOnsTitle.forEach((element, index) => {
                        $(".add_ons_list").append('<div class="row" style="margin-top:5px;" id="add_ones_list_iteam_' + index + '"><div class="col-5"><input class="form-control" type="text" value="' + element + '" disabled ></div><div class="col-5"><input class="form-control" type="text" value="' + product.addOnsPrice[index] + '" disabled ></div><div class="col-2"><button class="btn" type="button" onclick="deleteAddOnesSingle(' + index + ')"><span class="fa fa-trash"></span></button></div></div>');
                    })

                    addOnesTitle = product.addOnsTitle;
                    addOnesPrice = product.addOnsPrice;
                }

                jQuery("#data-table_processing").hide();

            })


            $(".save_food_btn").click( async function () {

                var name = $(".food_name").val();
                var price = $(".food_price").val();
                var quantity = $(".item_quantity").val();
                var restaurant = $("#food_restaurant option:selected").val();
                var category = $("#food_category option:selected").val();

                var foodCalories = parseInt($(".food_calories").val());
                var foodGrams = parseInt($(".food_grams").val());
                var foodProteins = parseInt($(".food_proteins").val());
                var foodFats = parseInt($(".food_fats").val());
                var description = $("#food_description").val();
                var foodPublish = $(".food_publish").is(":checked");
                var nonveg = $(".food_nonveg").is(":checked");
                var veg = !nonveg;
                var foodTakeaway = $(".food_take_away_option").is(":checked");
                var discount = $(".food_discount").val();
                if (discount == '') {
                    discount = "0";
                }
                if (!foodCalories) {
                    foodCalories = 0;
                }
                if (!foodGrams) {
                    foodGrams = 0;
                }
                if (!foodFats) {
                    foodFats = 0;
                }
                if (!foodProteins) {
                    foodProteins = 0;
                }

                if (photos.length > 0) {
                    photo = photos[0];
                } else {
                    photo = '';
                }

                if (name == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.enter_food_name_error')}}</p>");
                    window.scrollTo(0, 0);
                } else if (price == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.enter_food_price_error')}}</p>");
                    window.scrollTo(0, 0);
                } else if (restaurant == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.select_restaurant_error')}}</p>");
                    window.scrollTo(0, 0);
                } else if (category == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.select_food_category_error')}}</p>");
                    window.scrollTo(0, 0);
                } else if (parseInt(price) < parseInt(discount)) {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.price_should_not_less_then_discount_error')}}</p>");
                    window.scrollTo(0, 0);

                } else if (quantity == '' || quantity < -1) {
                    $(".error_top").show();
                    $(".error_top").html("");
                    if (quantity == '') {
                        $(".error_top").append("<p>{{trans('lang.enter_item_quantity_error')}}</p>");
                    } else {
                        $(".error_top").append("<p>{{trans('lang.invalid_item_quantity_error')}}</p>");
                    }
                    window.scrollTo(0, 0);
                } else if (description == '') {
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>{{trans('lang.enter_food_description_error')}}</p>");
                    window.scrollTo(0, 0);
                } else {

                    $(".error_top").hide();
                    var quantityerror = 0;
                    var priceerror = 0;
                    var attributes = [];
                    var variants = [];

                    if ($('#attributes').val().length > 0) {
                        var attributes = $.parseJSON($('#attributes').val());
                    }
                    if ($('#variants').val().length > 0) {
                        var variantsSet = $.parseJSON($('#variants').val());
                        await storeVariantImageData().then(async (vIMG) => {

                            $.each(variantsSet, function (key, variant) {
                            var variant_id = uniqid();
                            var variant_sku = variant;

                            var variant_price = $('[id="price_' + variant + '"]').val();
                            var variant_quantity = $('[id="qty_' + variant + '"]').val();
                            var variant_image = $('[id="variant_' + variant + '_url"]').val();

                            if (variant_image) {
                                variants.push({
                                    'variant_id': variant_id,
                                    'variant_sku': variant_sku,
                                    'variant_price': variant_price,
                                    'variant_quantity': variant_quantity,
                                    'variant_image': variant_image
                                });
                            } else {
                                variants.push({
                                    'variant_id': variant_id,
                                    'variant_sku': variant_sku,
                                    'variant_price': variant_price,
                                    'variant_quantity': variant_quantity
                                });
                            }

                            if (variant_quantity = '' || variant_quantity < -1 || variant_quantity == 0) {

                                quantityerror++;
                            }
                            if (variant_price == "" || variant_price <= 0) {
                                priceerror++;
                            }

                        });
                        }).catch(err => {
                            jQuery("#data-table_processing").hide();
                            $(".error_top").show();
                            $(".error_top").html("");
                            $(".error_top").append("<p>" + err + "</p>");
                            window.scrollTo(0, 0);
                        });

                    }


                    var item_attribute = null;
                    if (attributes.length > 0 && variants.length > 0) {
                        if (quantityerror > 0) {
                            alert('Please add your variants quantity it should be -1 or greater than -1');
                            return false;
                        }
                        if (priceerror > 0) {
                            alert('Please add your variants  Price');
                            return false;
                        }
                        var item_attribute = {'attributes': attributes, 'variants': variants};
                    }


                    if ($.isEmptyObject(product_specification)) {
                        product_specification = null;
                    }
                    jQuery("#data-table_processing").show();

                await storeImageData().then(async (IMG) => { 
                    if (IMG.length > 0) {
                        photo = IMG[0];
                    }

                    database.collection('vendor_products').doc(id).update({
                        'name': name,
                        'price': price.toString(),
                        'quantity': parseInt(quantity),
                        'disPrice': discount,
                        'vendorID': restaurant,
                        'categoryID': category,
                        'photo': photo,
                        'calories': foodCalories,
                        "grams": foodGrams,
                        'proteins': foodProteins,
                        'fats': foodFats,
                        'description': description,
                        'publish': foodPublish,
                        'nonveg': nonveg,
                        'veg': veg,
                        'addOnsTitle': addOnesTitle,
                        'addOnsPrice': addOnesPrice,
                        'takeawayOption': foodTakeaway,
                        'product_specification': product_specification,
                        'item_attribute': item_attribute,
                        'photos': IMG
                    }).then(function (result) {

                        <?php if(isset($_GET['eid']) && $_GET['eid'] != ''){?>

                            window.location.href = "{{ route('restaurants.foods',$_GET['eid']) }}";
                        <?php }else{ ?>
                        jQuery("#data-table_processing").hide();

                            window.location.href = '{{ route("foods")}}';

                        <?php } ?>
                        window.location.href = '{{ route("foods")}}';

                    });
                }).catch(err => {
                    jQuery("#data-table_processing").hide();
                    $(".error_top").show();
                    $(".error_top").html("");
                    $(".error_top").append("<p>" + err + "</p>");
                    window.scrollTo(0, 0);
                });

                }

            })

        })

        function handleFileSelect(evt) {
            var f = evt.target.files[0];
            var reader = new FileReader();
            new Compressor(f, {
                quality: <?php echo env('IMAGE_COMPRESSOR_QUALITY', 0.8); ?>,
                success(result) {
                    f = result;
                    reader.onload = (function (theFile) {
                        return function (e) {

                            var filePayload = e.target.result;
                            var val = f.name;
                            var ext = val.split('.')[1];
                            var docName = val.split('fakepath')[1];
                            var filename = (f.name).replace(/C:\\fakepath\\/i, '')

                            var timestamp = Number(new Date());
                            var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                            var uploadTask = storageRef.child(filename).put(theFile);
                            uploadTask.on('state_changed', function (snapshot) {
                                var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                                console.log('Upload is ' + progress + '% done');
                                jQuery("#uploding_image").text("Image is uploading...");

                            }, function (error) {
                            }, function () {
                                uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                                    jQuery("#uploding_image").text("Upload is completed");
                                    photo = downloadURL;
                                    $(".item_image").empty()
                                    $(".item_image").append('<img class="rounded" style="width:50px" src="' + photo + '" alt="image">');

                                });
                            });

                        };
                    })(f);
                    reader.readAsDataURL(f);
                },
                error(err) {
                    console.log(err.message);
                },
            });
        }

        function addOneFunction() {
            $("#add_ones_div").show();
            $(".save_add_one_btn").show();
        }

        function saveAddOneFunction() {
            var optiontitle = $(".add_ons_title").val();
            var optionPricevalue = $(".add_ons_price").val();
            var optionPrice = $(".add_ons_price").val();
            $(".add_ons_price").val('');
            $(".add_ons_title").val('');
            if (optiontitle != '' && optionPricevalue != '') {
                addOnesPrice.push(optionPrice.toString());
                addOnesTitle.push(optiontitle);
                var index = addOnesTitle.length - 1;
                $(".add_ons_list").append('<div class="row" style="margin-top:5px;" id="add_ones_list_iteam_' + index + '"><div class="col-5"><input class="form-control" type="text" value="' + optiontitle + '" disabled ></div><div class="col-5"><input class="form-control" type="text" value="' + optionPrice + '" disabled ></div><div class="col-2"><button class="btn" type="button" onclick="deleteAddOnesSingle(' + index + ')"><span class="fa fa-trash"></span></button></div></div>');
            } else {
                $(".error_top").show();
                $(".error_top").html("");
                $(".error_top").append("<p>{{trans('lang.enter_title_and_price_error')}}</p>");
                window.scrollTo(0, 0);
                // alert("Please enter Title and Price");
            }
        }

        function deleteAddOnesSingle(index) {
            addOnesTitle.splice(index, 1);
            addOnesPrice.splice(index, 1);
            $("#add_ones_list_iteam_" + index).hide();
        }



        function handleFileSelectProduct(evt) {
            var f = evt.target.files[0];
            var reader = new FileReader();
            reader.onload = (function (theFile) {
                return function (e) {

                    var filePayload = e.target.result;
                    var val = f.name;
                    var ext = val.split('.')[1];
                    var docName = val.split('fakepath')[1];
                    var filename = (f.name).replace(/C:\\fakepath\\/i, '')

                    var timestamp = Number(new Date());
                    var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                    var uploadTask = storageRef.child(filename).put(theFile);
                    console.log(uploadTask);
                    uploadTask.on('state_changed', function (snapshot) {

                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        console.log('Upload is ' + progress + '% done');

                        $('.product_image').find(".uploding_image_photos").text("Image is uploading...");

                    }, function (error) {
                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            jQuery("#uploding_image").text("Upload is completed");
                            if (downloadURL) {

                                productImagesCount++;
                                photos_html = '<span class="image-item" id="photo_' + productImagesCount + '"><span class="remove-btn" data-id="' + productImagesCount + '" data-img="' + downloadURL + '"><i class="fa fa-remove"></i></span><img class="rounded" width="50px" id="" height="auto" src="' + downloadURL + '"></span>'
                                $(".product_image").append(photos_html);
                                photos.push(downloadURL);

                            }

                        });
                    });

                };
            })(f);
            reader.readAsDataURL(f);
        }
        async function storeImageData() {
            var newPhoto = [];
            if (photos.length > 0) {
                newPhoto = photos;
            }
            if (new_added_photos.length > 0) {
                await Promise.all(new_added_photos.map(async (foodPhoto, index) => {

                    foodPhoto = foodPhoto.replace(/^data:image\/[a-z]+;base64,/, "");
                    var uploadTask = await storageRef.child(new_added_photos_filename[index]).putString(foodPhoto, 'base64', { contentType: 'image/jpg' });
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    newPhoto.push(downloadURL);
                }));
            }
            if (photosToDelete.length > 0) {
                /*await Promise.all(photosToDelete.map(async (delImage) => {
                    delImage.delete();
                    console.log("Image deleted");

                }));*/

            }
            return newPhoto;
        }

        $("#product_image").resizeImg({

            callback: function (base64str) {

                var val = $('#product_image').val().toLowerCase();
                var ext = val.split('.')[1];
                var docName = val.split('fakepath')[1];
                var filename = $('#product_image').val().replace(/C:\\fakepath\\/i, '')
                var timestamp = Number(new Date());
                var filename = filename.split('.')[0] + "_" + timestamp + '.' + ext;
                productImagesCount++;
                photos_html = '<span class="image-item" id="photo_' + productImagesCount + '"><span class="remove-btn" data-id="' + productImagesCount + '" data-img="' + base64str + '" data-status="new"><i class="fa fa-remove"></i></span><img class="rounded" width="50px" id="" height="auto" src="' + base64str + '"></span>'
                $(".product_image").append(photos_html);
                new_added_photos.push(base64str);
                new_added_photos_filename.push(filename);
                $("#product_image").val('');

                //upload base64str encoded string as a image to firebase
                /*var uploadTask = storageRef.child(filename).putString(base64str.split(',')[1], "base64", {contentType: 'image/' + ext})

                uploadTask.on('state_changed', function (snapshot) {
                    var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                }, function (error) {
                }, function () {
                    uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                        jQuery("#uploding_image").text("Upload is completed");
                        productImagesCount++;
                        photos_html = '<span class="image-item" id="photo_' + productImagesCount + '"><span class="remove-btn" data-id="' + productImagesCount + '" data-img="' + downloadURL + '"><i class="fa fa-remove"></i></span><img class="rounded" width="50px" id="" height="auto" src="' + downloadURL + '"></span>'
                        $(".product_image").append(photos_html);
                        photos.push(downloadURL);
                        $("#product_image").val('');
                    });
                });*/
            }
        });


        $(document).on("click", ".remove-btn", function () {
            var id = $(this).attr('data-id');
            var photo_remove = $(this).attr('data-img');
            var status=$(this).attr('data-status');
            if(status=="old"){

                 photosToDelete.push(firebase.storage().refFromURL(photo_remove));
            }

            $("#photo_" + id).remove();
            index = photos.indexOf(photo_remove);
            if (index > -1) {
                photos.splice(index, 1); // 2nd parameter means remove one item only
            }
            index = new_added_photos.indexOf(photo_remove);
            if (index > -1) {
                new_added_photos.splice(index, 1); // 2nd parameter means remove one item only
                new_added_photos_filename.splice(index, 1);
            }

        });

        $("#food_restaurant").change(function () {

            $("#attributes_div").show();
            $("#item_attribute_chosen").css({'width': '100%'});

            var selected_vendor = this.value;

        });

        function change_categories(selected_vendor) {
            restaurant_list.forEach((vendor) => {
                if (vendor.id == selected_vendor) {

                    $('#item_category').html('');
                    $('#item_category').append($('<option value="">{{trans("lang.select_category")}}</option>'));
                    console.log(vendor.categoryID);
                    categories_list.forEach((data) => {
                        console.log(data.id);
                        if (vendor.categoryID == data.id) {
                            $('#food_category').html($("<option></option>")
                                .attr("value", data.id)
                                .text(data.title));
                        }
                    })
                }
            });
        }
        function handleVariantFileSelect(evt, vid) {
            var f = evt.target.files[0];
            var reader = new FileReader();

            reader.onload = (function (theFile) {
                return function (e) {

                    var filePayload = e.target.result;
                    var val = f.name;
                    var ext = val.split('.')[1];
                    var docName = val.split('fakepath')[1];
                    var timestamp = Number(new Date());
                    var filename = (f.name).replace(/C:\\fakepath\\/i, '')
                    var filename = 'variant_' + vid + '_' + timestamp + '.' + ext;
                    variant_filename.push(filename);
                    variant_photos.push(filePayload);
                    variant_vIds.push(vid);
                    $('[id="variant_'+ vid+'_image"]').empty();
                    $('[id="variant_'+ vid+'_image"]').html('<img class="rounded" style="width:50px" src="' + filePayload + '" alt="image"><i class="mdi mdi-delete" data-variant="' + vid + '" data-img="' +filePayload + '" data-file="'+filename +'" data-status="new"></i>');
                    $('#upload_'+vid).attr('data-img',filePayload);
                    $('#upload_'+vid).attr('data-file',filename);

                   /* var uploadTask = storageRef.child(filename).put(theFile);
                    uploadTask.on('state_changed', function (snapshot) {
                        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                        console.log('Upload is ' + progress + '% done');
                        $('[id="variant_' + vid + '_process"]').text("Image is uploading...");

                    }, function (error) {
                    }, function () {
                        uploadTask.snapshot.ref.getDownloadURL().then(function (downloadURL) {
                            var oldurl = $('[id="variant_' + vid + '_url"]').val();
                            if (oldurl) {
                                firebase.storage().refFromURL(oldurl).delete();
                            }
                            $('[id="variant_' + vid + '_process"]').text("Upload is completed");
                            $('[id="variant_' + vid + '_image"]').empty();
                            $('[id="variant_' + vid + '_url"]').val(downloadURL);
                            $('[id="variant_' + vid + '_image"]').html('<img class="rounded" style="width:50px" src="' + downloadURL + '" alt="image"><i class="mdi mdi-delete" data-variant="' + vid + '"></i>');
                            setTimeout(function () {
                                $('[id="variant_' + vid + '_process"]').empty();
                            }, 1000);
                        });
                    });*/

                };
            })(f);
            reader.readAsDataURL(f);
        }
        async function storeVariantImageData() {
            var newPhoto = [];
            console.log(variant_photos);
            console.log(variant_filename);
            console.log(variant_vIds);
            if (variant_photos.length > 0) {
                await Promise.all(variant_photos.map(async (variantPhoto, index) => {
                    variantPhoto = variantPhoto.replace(/^data:image\/[a-z]+;base64,/, "");
                    var uploadTask = await storageRef.child(variant_filename[index]).putString(variantPhoto, 'base64', {contentType: 'image/jpg'});
                    var downloadURL = await uploadTask.ref.getDownloadURL();
                    $('[id="variant_'+ variant_vIds[index]+'_url"]').val(downloadURL);
                    newPhoto.push(downloadURL);
                }));
            }
            console.log(variantImageToDelete);
            if (variantImageToDelete.length > 0) {
                /*await Promise.all(variantImageToDelete.map(async (delVariant) => {
                    firebase.storage().refFromURL(delVariant).delete();
                        console.log("Image deleted");
                }));*/

            }
            return newPhoto;
        }

function selectAttribute(item_attribute = '') {

if (item_attribute) {
var item_attribute = $.parseJSON(atob(item_attribute));
}

var html = '';
$("#item_attribute").find('option:selected').each(function () {
var $this = $(this);
var selected_options = [];
if (item_attribute) {
$.each(item_attribute.attributes, function (index, attribute) {
if ($this.val() == attribute.attribute_id) {
selected_options.push(attribute.attribute_options);
}
});
}
html += '<div class="row" id="attr_' + $this.val() + '">';
html += '<div class="col-md-3">';
html += '<label>' + $this.text() + '</label>';
html += '</div>';
html += '<div class="col-lg-9">';
html += '<input type="text" class="form-control" id="attribute_options_' + $this.val() + '" value="' + selected_options + '" placeholder="Add attribute values" data-role="tagsinput" onchange="variants_update(\'' + btoa(JSON.stringify(item_attribute)) + '\')">';
html += '</div>';
html += '</div>';
});
$("#item_attributes").html(html);
$("#item_attributes input[data-role=tagsinput]").tagsinput();

if ($("#item_attribute").val().length == 0) {
$("#attributes").val('');
$("#variants").val('');
$("#item_variants").html('');
}
}

function variants_update(item_attributeX = '') {

if (item_attributeX) {
var item_attributeX = $.parseJSON(atob(item_attributeX));
}

var html = '';
var item_attribute = $("#item_attribute").map(function (idx, ele) {
return $(ele).val();
}).get();

if (item_attribute.length > 0) {

var attributes = [];
var attributeSet = [];
$.each(item_attribute, function (index, attribute) {
var attribute_options = $("#attribute_options_" + attribute).val();
if (attribute_options) {
var attribute_options = attribute_options.split(',');
attribute_options = $.map(attribute_options, function (value) {
return value.replace(/[^0-9a-zA-Z a]/g, '');
});
attributeSet.push(attribute_options);
attributes.push({'attribute_id': attribute, 'attribute_options': attribute_options});
}
});

if (attributeSet.length > 0) {

$('#attributes').val(JSON.stringify(attributes));

var variants = getCombinations(attributeSet);
$('#variants').val(JSON.stringify(variants));

html += '<table class="table table-bordered">';
html += '<thead class="thead-light">';
html += '<tr>';
html += '<th class="text-center"><span class="control-label">Variant</span></th>';
html += '<th class="text-center"><span class="control-label">Variant Price</span></th>';
html += '<th class="text-center"><span class="control-label">Variant Quantity</span></th>';
html += '<th class="text-center"><span class="control-label">Variant Image</span></th>';
html += '</tr>';
html += '</thead>';
html += '<tbody>';
$.each(variants, function (index, variant) {

var variant_price = 1;
var variant_qty = -1;
var variant_image = variant_image_url = '';
if (item_attributeX) {
var variant_info = $.map(item_attributeX.variants, function (v, i) {
 if (v.variant_sku == variant) {
     return v;
 }
});
if (variant_info[0]) {
 variant_price = variant_info[0].variant_price;
 variant_qty = variant_info[0].variant_quantity;
 if (variant_info[0].variant_image) {
     variant_image = '<img class="rounded" style="width:50px" src="' + variant_info[0].variant_image + '" alt="image"><i class="mdi mdi-delete" data-variant="' + variant + '" data-status="old"></i>';
     variant_image_url = variant_info[0].variant_image;
 }
}
}

html += '<tr>';
html += '<td><label for="" class="control-label">' + variant + '</label></td>';
html += '<td>';
html += '<input type="number" id="price_' + variant + '" value="' + variant_price + '" min="0" class="form-control">';
html += '</td>';
html += '<td>';
html += '<input type="number" id="qty_' + variant + '" value="' + variant_qty + '" min="-1" class="form-control">';
html += '</td>';
html += '<td>';
html += '<div class="variant-image">';
html += '<div class="upload">';
html += '<div class="image" id="variant_' + variant + '_image">' + variant_image + '</div>';
html += '<div class="icon"><i class="mdi mdi-cloud-upload" data-variant="' + variant + '" id="upload_'+variant+'"></i></div>';
html += '</div>';
html += '<div id="variant_' + variant + '_process"></div>';
html += '<div class="input-file">';
html += '<input type="file" id="file_' + variant + '" onChange="handleVariantFileSelect(event,\'' + variant + '\')" class="form-control" style="display:none;">';
html += '<input type="hidden" id="variant_' + variant + '_url" value="' + variant_image_url + '">';
html += '</div>';
html += '</div>';
html += '</td>';
html += '</tr>';
});
html += '</tbody>';
html += '</table>';
}
}
$("#item_variants").html(html);
}

function getCombinations(arr) {
if (arr.length) {
if (arr.length == 1) {
return arr[0];
} else {
var result = [];
var allCasesOfRest = getCombinations(arr.slice(1));
for (var i = 0; i < allCasesOfRest.length; i++) {
for (var j = 0; j < arr[0].length; j++) {
result.push(arr[0][j] + '-' + allCasesOfRest[i]);
}
}
return result;
}
}
}

function uniqid(prefix = "", random = false) {
const sec = Date.now() * 1000 + Math.random() * 1000;
const id = sec.toString(16).replace(/\./g, "").padEnd(14, "0");
return `${prefix}${id}${random ? `.${Math.trunc(Math.random() * 100000000)}` : ""}`;
}

function addProductSpecificationFunction() {
$("#add_product_specification_div").show();
$(".save_product_specification_btn").show();
}

function saveProductSpecificationFunction() {
var optionlabel = $(".add_label").val();
var optionvalue = $(".add_value").val();
$(".add_label").val('');
$(".add_value").val('');

if (optionlabel != '' && optionvalue != '') {
if (product_specification == null) {
product_specification = {};
}

product_specification[optionlabel] = optionvalue;

$(".product_specification").append('<div class="row add_product_specification_iteam_' + optionlabel + '" style="margin-top:5px;" id="add_product_specification_iteam_' + optionlabel + '"><div class="col-5"><input class="form-control" type="text" value="' + optionlabel + '" disabled ></div><div class="col-5"><input class="form-control" type="text" value="' + optionvalue + '" disabled ></div><div class="col-2"><button class="btn" type="button" onclick=deleteProductSpecificationSingle("' + optionlabel + '")><span class="fa fa-trash"></span></button></div></div>');
} else {
alert("Please enter Label and Value");
}
}

function deleteProductSpecificationSingle(index) {

delete product_specification[index];
$(".add_product_specification_iteam_" + index).addClass('hide');
}
</script>
@endsection
