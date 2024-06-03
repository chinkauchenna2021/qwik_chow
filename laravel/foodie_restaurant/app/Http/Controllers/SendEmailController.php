<?php

namespace App\Http\Controllers;

use App\Mail\SetEmailData;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Redirect;

class SendEmailController extends Controller
{
    public function __construct()
    {
    }


    function sendMail(Request $request)
    {

        $data = $request->all();

        $subject = $data['subject'];
        $message = $data['message'];
        $recipients = $data['recipients'];

        Mail::to($recipients)->send(new SetEmailData($subject, $message));

        return "email sent successfully!";
    }
}

?>