<?php
namespace AppBundle\RequestLogger\Logger;

use Psr\Log\LoggerInterface;

interface RetrievableLogsInterface extends LoggerInterface
{
    public function getLogs():array;
}
