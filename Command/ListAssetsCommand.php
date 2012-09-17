<?php

namespace Room13\AsseticServerBundle\Command;

use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;


class ListAssetsCommand extends ContainerAwareCommand
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
            ->setName('room13:assetic-server:list-assets')
            ->setDescription('Lists available assetic groups and their files')
            ->addArgument('format',InputArgument::OPTIONAL,'formate to dump in plain,json are allowed','plain')
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        $this->container = $this->getContainer();
        $this->assetic = $this->container->get('assetic.asset_manager');
        $files = array();
        foreach($this->assetic->getNames() as $name)
        {
            $asset = $this->assetic->get($name);
            $group = array();

            foreach ($asset as $assetPart)
            {
                $absPath = realpath($assetPart->getSourceRoot().'/'.$assetPart->getSourcePath());
                if($absPath===false)
                {
                    continue;
                }

                $group[]=$assetPart->getTargetPath();
                $files[$assetPart->getTargetPath()]=$absPath;
            }

            $files[$asset->getTargetPath()]=$group;

        }

        switch($input->getArgument('format'))
        {
            case 'json':
                $output->write(json_encode($files));
                break;
            default:
                $output->write(var_export($files,true));
                break;
        }



    }


}