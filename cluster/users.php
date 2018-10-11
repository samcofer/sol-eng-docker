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
            'email' => 'joe@test.com',
        ),
        'julie:julie' => array(
            'uid' => array('1001'),
            'eduPersonAffiliation' => array('engineering'),
	    'user' => 'julie',
            'email' => 'julie@test.com',
        ),
        'bobo:momo' => array(
            'uid' => array('1002'),
            'eduPersonAffiliation' => array('finance'),
	    'user' => 'bobo',
            'email' => 'bobo@etest.com',
        ),
        'john:john' => array(
            'uid' => array('1003'),
            'eduPersonAffiliation' => array('finance'),
	    'user' => 'john',
            'email' => 'john@etest.com',
        ),
        'jen:jen' => array(
            'uid' => array('1004'),
            'eduPersonAffiliation' => array('support'),
	    'user' => 'jen',
            'email' => 'jen@test.com',
        ),
        'test:test' => array(
            'uid' => array('1005'),
            'eduPersonAffiliation' => array('support'),
	    'user' => 'test',
            'email' => 'test@test.com',
        ),
    ),
);
