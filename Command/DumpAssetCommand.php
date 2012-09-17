<?php

namespace Room13\AsseticServerBundle\Command;

use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Assetic\Asset\AssetInterface;

class DumpAssetCommand extends ContainerAwareCommand
{

    /**
     * @var \Assetic\AssetManager
     */
    private $assetic;

    /**
     * @var \Symfony\Component\DependencyInjection\Container
     */
    private $container;

    public function configure()
    {

        $this
            ->setName('room13:assetic-server:dump-asset')
            ->setDescription('Dumps a processed assetic asset')
            ->addArgument('group',InputArgument::REQUIRED,'assetic group')
            ->addArgument('index',InputArgument::OPTIONAL,'index of assetic group',false)
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        $this->container = $this->getContainer();
        $this->assetic = $this->container->get('assetic.asset_manager');

        $asset = $this->assetic->get($input->getArgument('group'));
        $allAssets = $asset->all();

        $content = null;
        if($input->getArgument('index') !== false)
        {
            $subAsset = $allAssets[intval($input->getArgument('index'))-1];
            $content = $this->dump($subAsset);
            echo $content;
        }
        else
        {
            foreach($allAssets as $subAsset)
            {
                echo $this->dump($subAsset);
            }
        }


    }

    public function dump(AssetInterface $asset)
    {

        $writer = new \Assetic\AssetWriter(sys_get_temp_dir(), $this->container->getParameter('assetic.variables'));
        $ref = new \ReflectionMethod($writer, 'getCombinations');
        $ref->setAccessible(true);
        $name = $asset->getSourcePath();
        $type = substr($name,strrpos($name,'.')+1);

        switch($type)
        {
            case 'coffee':
                $asset->ensureFilter($this->container->get('assetic.filter.coffee'));
                $type = 'js';
                break;
            case 'less':
                $asset->ensureFilter($this->container->get('assetic.filter.less'));
                $type = 'css';
                break;
        }

        $combinations = $ref->invoke($writer, $asset->getVars());
        $asset->setValues($combinations[0]);
        $asset->load();
        $content = $asset->getContent();

        // because the assetic cssrewrite makes bullshit here, we need to reimplement the filter
        if($type==='css')
        {
            $content = $this->cssFilter($content,'/'.dirname($asset->getSourcePath()));
        }

        return $content;
    }


    private function cssFilter($content,$baseUrl)
    {
        // rewrite url(..) definitions
        $content = preg_replace_callback('/url\((["\']?)(?P<url>.*?)(\\1)\)/', function($matches) use($baseUrl)
        {
            $url = $baseUrl.'/'.$matches['url'];
            return 'url('.$url.')';
        }, $content);

        // rewrite @import ... definitions
        $content = preg_replace_callback('/@import (?!url\()(\'|"|)(?P<url>[^\'"\)\n\r]*)\1;?/',function($matches) use($baseUrl)
        {
            $url = $baseUrl.'/'.$matches['url'];
            return '@import "'.$url.'"';
        },$content);

        // rewrite ie filters like alpha
        $content = preg_replace_callback('/src=(["\']?)(?<url>.*?)\\1/', function($matches) use ($baseUrl)
        {
            $url = $baseUrl.'/'.$matches['url'];
            return $url;
        },$content);

        return $content;
    }


}