<?php
/**
 * File name: RestaurantController.php
 * Last modified: 2020.04.30 at 08:21:08
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2020
 *
 */

namespace App\Http\Controllers;

class RestaurantController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }
    
	  public function index()
    {

        return view("restaurants.index");
    }
    public function vendors()
    {
        return view("vendors.index");
    }


  public function edit($id)
    {
    	    return view('restaurants.edit')->with('id',$id);
    }

    public function view($id)
    {
        return view('restaurants.view')->with('id',$id);
    }

    public function payout($id)
    {
        return view('restaurants.payout')->with('id',$id);
    }

    public function foods($id)
    {
        return view('restaurants.foods')->with('id',$id);
    }

    public function orders($id)
    {
        return view('restaurants.orders')->with('id',$id);
    }

    public function reviews($id)
    {
        return view('restaurants.reviews')->with('id',$id);
    }

    public function promos($id)
    {
        return view('restaurants.promos')->with('id',$id);
    }

    public function create(){
        return view('restaurants.create');
    }


}
