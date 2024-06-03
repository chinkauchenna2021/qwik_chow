<?php

namespace App\Http\Controllers;


class RestaurantFiltersController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }
    
    public function index()
    {
        return view('restaurant_filters.index');
    }


    public function edit($id)
    {
        
        return view('restaurant_filters.edit')->with('id',$id);
    }

    public function create()
    {
        return view('restaurant_filters.create');
    }    
}
