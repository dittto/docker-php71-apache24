<?php
namespace Dittto\CachedRequestBundle\GuzzleMiddleware;

use GuzzleHttp\Exception\TransferException;
use GuzzleHttp\Promise\FulfilledPromise;
use GuzzleHttp\Promise\RejectedPromise;
use Psr\Http\Message\{
    RequestInterface, ResponseInterface
};
use Psr\SimpleCache\CacheInterface;

class CachedMiddleware
{
    public const CACHE_TIME_IN_S = 'cache_time';
    private const DEFAULT_CACHE_TIME = 5;

    public function onRequest(CacheInterface $cache, int $defaultCacheTime = self::DEFAULT_CACHE_TIME, bool $isCachedOnFailure = false)
    {
        return function (callable $handler) use ($cache, $defaultCacheTime, $isCachedOnFailure) {
            return function (RequestInterface $request, array $options) use ($handler, $cache, $defaultCacheTime, $isCachedOnFailure) {

                $cacheKey = sha1((string) $request->getUri());

                if ($cachedResponse = $cache->get($cacheKey)) {
                    var_dump('is_cached');
                    return new FulfilledPromise($cachedResponse);
                }

                $cacheTime = $options[self::CACHE_TIME_IN_S] ?? $defaultCacheTime;

                return $handler($request, $options)->then(
                    function (ResponseInterface $response) use ($request, $cache, $cacheKey, $cacheTime) {

                        var_dump('caching');
                        $cache->set($cacheKey, $response, $cacheTime);

                        return $response;
                    },
                    function (TransferException $e) use ($request, $cache, $cacheKey, $cacheTime, $isCachedOnFailure) {

                        var_dump('failed');
                        if ($isCachedOnFailure) {
                            $cache->set($cacheKey, $e, $cacheTime);
                        }

                        return new RejectedPromise($e);
                    }
                );
            };
        };
    }
}
