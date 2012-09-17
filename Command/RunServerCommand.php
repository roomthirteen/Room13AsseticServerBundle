<?php

namespace Room13\AsseticServerBundle\Command;

use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Assetic\Asset\AssetInterface;

class RunServerCommand extends ContainerAwareCommand
{
    public function configure()
    {

        $this
            ->setName('room13:assetic-server:run')
            ->setDescription('Runs the assetic server. Just a symfony command wrapper to start the node server')
        ;
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        $container = $this->getContainer();
        $kernel = $container->get('kernel');
        $bundle = $kernel->getBundle('Room13AsseticServerBundle');

        $cmd = sprintf(
            'coffee %s %s %s %s %s %s',
            $bundle->getPath().'/Resources/node/Main.coffee',
            $container->getParameter('room13.assetic-server.config.port'),
            $kernel->getRootDir(),
            $container->getParameter('room13.assetic-server.config.documentRoot'),
            $kernel->getEnvironment(),
            $container->getParameter('room13.assetic-server.config.consoleCommand')

        );

        $p = popen($cmd,'r');
        fpassthru($p);


    }


}