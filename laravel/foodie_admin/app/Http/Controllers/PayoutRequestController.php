<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PayoutRequestController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index($id = '')
    {
        return view("payoutRequests.drivers.index")->with('id',$id);
    }

    public function restaurant($id = '')
    {
        return view("payoutRequests.restaurants.index")->with('id',$id);
    }

}
