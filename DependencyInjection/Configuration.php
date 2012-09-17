<?php

namespace Room13\AsseticServerBundle\DependencyInjection;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;

/**
 * This is the class that validates and merges configuration from your app/config files
 *
 * To learn more see {@link http://symfony.com/doc/current/cookbook/bundles/extension.html#cookbook-bundles-extension-config-class}
 */
class Configuration implements ConfigurationInterface
{
    /**
     * {@inheritDoc}
     */
    public function getConfigTreeBuilder()
    {
        $treeBuilder = new TreeBuilder();
        $rootNode = $treeBuilder->root('room13_assetic_server');

        $rootNode
        ->children()
            ->booleanNode('enabled')->defaultTrue()->end()
            ->scalarNode('port')->cannotBeEmpty()->defaultValue(8124)->end()
            ->scalarNode('documentRoot')->cannotBeEmpty()->defaultValue('web')->end()
            ->scalarNode('consoleCommand')->cannotBeEmpty()->defaultValue('./bin/console')->end()
        ->end()
    ;


        return $treeBuilder;
    }
}
