<?php
/**
 * Sample plugin to try out some hooks.
 * This performs an automatic login if accessed from localhost
 *
 * @license GNU GPLv3+
 * @author Thomas Bruederli
 */
class autologon extends rcube_plugin
{
  public $task = 'login';
  function init()
  {
    $this->add_hook('startup', array($this, 'startup'));
    $this->add_hook('authenticate', array($this, 'authenticate'));
  }
  function startup($args)
  {
    // change action to login
    if (empty($_SESSION['user_id']))
      $args['action'] = 'login';
    return $args;
  }
  function authenticate($args)
  {
    $args['user'] = 'smtp';
    $args['pass'] = 'smtp';
    $args['host'] = getenv("IMAP_HOSTNAME");
    $args['cookiecheck'] = false;
    $args['valid'] = true;
    return $args;
  }
}

