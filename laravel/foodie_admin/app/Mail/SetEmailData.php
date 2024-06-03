<?php


namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class SetEmailData extends Mailable
{
    use Queueable, SerializesModels;

    public $dynamicSubject;
    public $dynamicMessage;

    /**
     * Create a new message instance.
     *
     * @param string $subject
     * @param string $message
     * @return void
     */
    public function __construct($subject, $message)
    {
        $this->dynamicSubject = $subject;
        $this->dynamicMessage = $message;
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {
        return $this->subject($this->dynamicSubject)->view('settings.email.send_email')->with('data', $this->dynamicMessage);
    }
}


?>