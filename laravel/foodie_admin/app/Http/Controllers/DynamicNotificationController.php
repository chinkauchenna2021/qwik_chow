<?php

namespace App\Http\Controllers;

class DynamicNotificationController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        return view("dynamic_notifications.index");
    }


    public function save($id = null)
    {
        return view('dynamic_notifications.create')->with('id', $id);
    }

}