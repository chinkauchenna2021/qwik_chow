<?php

namespace App\Http\Controllers;


class RestaurantsPayoutController extends Controller
{  

   public function __construct()
    {
        $this->middleware('auth');
    }

    public function index($id='')
    {

       return view("restaurants_payouts.index")->with('id',$id);
    }

    public function create($id='')
    {
        
       return view("restaurants_payouts.create")->with('id',$id);
    }

}
