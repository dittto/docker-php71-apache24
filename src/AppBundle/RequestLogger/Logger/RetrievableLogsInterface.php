<?php
namespace AppBundle\RequestLogger\Logger;

interface RetrievableLogsInterface
{
    public function getLogs():array;
}
