<?php
namespace AppBundle\Controller;

use GuzzleHttp\ClientInterface;
use Symfony\Bundle\FrameworkBundle\Templating\EngineInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

class DefaultController
{
    private $templateEngine;
    private $client;
    private $projectDir;

    public function __construct(EngineInterface $templateEngine, ClientInterface $client, string $projectDir)
    {
        $this->templateEngine = $templateEngine;
        $this->client = $client;
        $this->projectDir = $projectDir;
    }

    public function index(Request $request)
    {
        $this->client->request('GET', 'https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-NAME=FindingService&SERVICE-VERSION=1.0.0&REST-PAYLOAD&GLOBAL-ID=EBAY-NLBE&SECURITY-APPNAME=trustedr-bff3-476c-bd74-168dff52ac0c&RESPONSE-DATA-FORMAT=JSON&paginationInput.pageNumber=1&affiliate.networkId=9&affiliate.trackingId=5337985180&keywords=Samsung+Galaxy+S8&sortOrder=BestMatch&paginationInput.entriesPerPage=1');

        return new JsonResponse(['test' => '1']);

        return $this->templateEngine->renderResponse(
            'default/index.html.twig',
            [
                'base_dir' => realpath($this->projectDir).DIRECTORY_SEPARATOR,
            ]
        );
    }
}