<?php
$config = array(
    'admin' => array(
        'core:AdminPassword',
    ),
    'example-userpass' => array(
        'exampleauth:UserPass',
        'joe:joe' => array(
            'uid' => array('1000'),
            'eduPersonAffiliation' => array('engineering'),
	    'user' => 'joe',
            'email' => 'joe@example.org',
        ),
        'julie:julie' => array(
            'uid' => array('1001'),
            'eduPersonAffiliation' => array('engineering'),
	    'user' => 'julie',
            'email' => 'julie@example.org',
        ),
        'bobo:momo' => array(
            'uid' => array('1002'),
            'eduPersonAffiliation' => array('finance'),
	    'user' => 'bobo',
            'email' => 'bobo@example.org',
        ),
        'john:john' => array(
            'uid' => array('1003'),
            'eduPersonAffiliation' => array('finance'),
	    'user' => 'john',
            'email' => 'john@example.org',
        ),
        'ashley:ashley' => array(
            'uid' => array('1003'),
            'eduPersonAffiliation' => array('finance'),
	    'user' => 'ashley',
            'email' => 'ashley@example.org',
        ),
        'jen:jen' => array(
            'uid' => array('1004'),
            'eduPersonAffiliation' => array('support'),
	    'user' => 'jen',
            'email' => 'jen@example.org',
        ),
        'test:test' => array(
            'uid' => array('1005'),
            'eduPersonAffiliation' => array('support'),
	    'user' => 'test',
            'email' => 'test@example.org',
        ),
    ),
);
